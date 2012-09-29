#!/bin/sh
lib=$1
tmpc=/tmp/rpath-check.c
tmpb=/tmp/rpath-check

if [ -z "$lib" ] ; then
	echo run "$0 check" to start a check
elif [ "$lib" = "check" ] ; then
	cat << EOF > $tmpc
	#include <stdio.h>
	#include <string.h>

	int main(int argc, char** argv) {
		if(argc > 1) {
			char* dir = strrchr(argv[1], '/');
			*dir = 0;
			char *ext;
			do { 
				ext = strrchr(dir + 1, '.');
				*ext = 0;
			} while (strcmp(ext+1, "so"));
			if(!memcmp(dir + 1, "lib", 3))
				printf("-L%s -l%s\n", argv[1], dir + 4);
		}
		return 0;
	}
EOF
	gcc -g -O0 $tmpc -o $tmpb || exit 1

	find /lib -name '*.so*' -exec $0 "{}" \;

else
	flags=`$tmpb $lib`
	echo $lib
	[ -z "$flags" ] || gcc test.c $flags 2>&1 | grep "needed by"
fi



