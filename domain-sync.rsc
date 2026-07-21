# -----------------------------------------------------------------------------
# Name:        domain-sync.rsc
# Project:     geo-hide
# Description: Synchronize RouterOS FQDN Address List from a GitHub-hosted
#              domain list.
#
# Tested on:
#   - RouterOS 7.23.2
#
# Repository:
#   https://github.com/M43R/Code/Infrastructure/mikrotik/scripts/geo-hide/
#
# License:
#   -
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Global Configuration
# -----------------------------------------------------------------------------

# Leave empty for public repositories.
:local githubToken ""

:local rawUrl "https://raw.githubusercontent.com/M43R/Code/main/Infrastructure/mikrotik/scripts/geo-hide/domains.txt"
:local listName "vpn_domains"
:local fileName "domains.txt"

# -----------------------------------------------------------------------------
# Download domains.txt
# -----------------------------------------------------------------------------

:if ([:len $githubToken] > 0) do={

    :log info "geo-hide: Downloading domains.txt from private GitHub repository..."

    :do {
        /tool fetch \
            url=$rawUrl \
            mode=https \
            http-header-field=("Authorization: Bearer " . $githubToken) \
            dst-path=$fileName

    } on-error={
        :log error "geo-hide: Failed to download domains.txt"
    }

} else={

    :log info "geo-hide: Downloading domains.txt from public GitHub repository..."

    :do {
        /tool fetch \
            url=$rawUrl \
            mode=https \
            dst-path=$fileName

    } on-error={
        :log error "geo-hide: Failed to download domains.txt"
    }

}

# -----------------------------------------------------------------------------
# Process downloaded file
# -----------------------------------------------------------------------------

:if ([/file find name=$fileName] != "") do={

    :local fileContent [/file get $fileName content]

    :log info ("geo-hide: Flushing old entries from " . $listName . "...")

    /ip firewall address-list remove [find where list=$listName dynamic=no]

    :local remain $fileContent
    :local line ""
    :local lineEnd
    :local imported 0

    :log info "geo-hide: Parsing domains.txt..."

    :while ([:len $remain] > 0) do={

        :set lineEnd [:find $remain "\n"]

        :if ([:type $lineEnd] = "nil") do={
            :set line $remain
            :set remain ""
        } else={
            :set line [:pick $remain 0 $lineEnd]
            :set remain [:pick $remain ($lineEnd + 1) [:len $remain]]
        }

        # Remove inline comments
        :local commentPos [:find $line "#"]

        :if ([:type $commentPos] != "nil") do={
            :set line [:pick $line 0 $commentPos]
        }

        # Trim line
        :local cleanLine ""

        :for i from=0 to=([:len $line] - 1) do={

            :local char [:pick $line $i ($i + 1)]

            :if (($char != "\r") && ($char != " ")) do={
                :set cleanLine ($cleanLine . $char)
            }
        }

        # Skip empty lines
        :if ([:len $cleanLine] > 0) do={

            :do {

                /ip firewall address-list add \
                    list=$listName \
                    address=$cleanLine \
                    comment="geo-hide"

                :set imported ($imported + 1)

            } on-error={

                :log warning ("geo-hide: Skipped invalid or duplicate entry '" . $cleanLine . "'")

            }

        }

    }

    /file remove $fileName

    :log info ("geo-hide: Update completed. Imported=" . $imported)

} else={

    :log error ("geo-hide: File '" . $fileName . "' not found after download!")

}