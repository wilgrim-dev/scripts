#!/bin/bash

FILE="$1"
SHEET="$2"

if [ -z "$FILE" ] || [ -z "$SHEET" ]; then
    echo "Usage: $0 <excel_file> <sheet_name>"
    exit 1
fi

# 2>/dev/null silences the DeprecationWarning
xlsx2csv -n "$SHEET" "$FILE" 2>/dev/null | awk -F',' '
BEGIN {
    print "--- Entries with > 2 Decimal Places ---"
    printf "%-10s | %-15s | %-20s\n", "Row", "Value", "Header Name"
    print "------------------------------------------------------------"
}
NR == 1 {
    # Store headers in an array
    for (i = 1; i <= NF; i++) {
        headers[i] = $i
    }
    next
}
{
    for (i = 1; i <= NF; i++) {
        # Regex: matches a dot followed by 3 or more digits
        if ($i ~ /\.[0-9]{3,}/) {
            # Use the headers array to print the name instead of column index
            printf "Row %-6d | %-15s | %s\n", NR, $i, (headers[i] != "" ? headers[i] : "Col " i)
            found = 1
        }
    }
}
END {
    if (!found) print "No entries found with more than 2 DP."
}'
