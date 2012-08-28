# Duplicate File Finder
**dup_finder** is a simple script to find duplicates within a set of directories. There are a multitude of existing solutions available, for example [Duff](http://duff.sourceforge.net) by Camilla Berglund. I wanted to create my own solution to allow for customizations when needed.

## Usage (Mac)
Clone the repo:

	$ git clone git@github.com:mfueger/dup_finder.git

Mark as executable (optional):

	$ chmod +x /path/to/dup_finder.rb

Symlink the script to make it available system-wide (optional):

	$ ln -s /path/to/dup_finder.rb /usr/local/bin/dff

Example for creating a script:

	$ dff -k short | xargs -n1 -I file echo cmd \"file\" >> script_file

Example for removing duplicate files directly:

	$ dff -k short | xargs -n1 rm

Get help:

	$ dff -h

### Notes

* With default options, the first file in a group will be kept.
* You can specify one or more directories to parse. If no directory is specified, the current working directory is used.
* By default, all but one file will be listed from a file group. Using the `-k none` switch will list all files, so use with caution.
* This script has been tested under Ruby 1.8.7 and 1.9.3.