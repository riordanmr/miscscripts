# extract_script_lines.awk - AWK script to read a file containing
# the script of a play and separate the lines spoken by each character.
# The script assumes that each line of dialogue starts with the character's
# name followed by a colon (e.g., "HAMLET: To be, or not to be...").
# The output will be a file for each character containing their lines.
#
# Usage: awk -f ~/Documents/GitHub/miscscripts/extract_script_lines.awk scriptmed.txt   

function parseLine(line, sepPos, leftSide) {
	sepPos = index(line, ":")
	if (sepPos == 0) {
		return 0
	}

	leftSide = substr(line, 1, sepPos - 1)
	if (leftSide !~ /^[A-Z .]+$/) {
		return 0
	}

	character = leftSide
	speech = substr(line, sepPos + 1)
	return 1
}

function computeFilename(charName) {
	charName = tolower(charName)
	gsub(/[^a-z]/, "", charName)
	return charName
}

{
    if (parseLine($0, sepPos, leftSide)) {
		filename = computeFilename(character) ".txt"
        # print filename
		speech = "... " speech
		if (!(filename in seenFiles)) {
			print speech > filename
			seenFiles[filename] = 1
		} else {
			print speech >> filename
		}
    }
}

END {
	for (file in seenFiles) {
		close(file)
		filenames = filenames file " "
	}
	print "Created files: " filenames
}
