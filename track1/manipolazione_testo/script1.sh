#!/bin/bash
sort $1 | uniq -c | sort -r | head -n 3
~                                        
