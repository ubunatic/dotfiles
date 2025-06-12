
#!/usr/bin/env python3
# Basic XML well-formedness check
import sys
import xml.etree.ElementTree as ET

filename = sys.argv[1]

try:
    ET.parse(filename)
    print(f"{filename} is well-formed.")
except ET.ParseError as e:
    print(f"{filename} is NOT well-formed:\n{e}")
    sys.exit(1)
