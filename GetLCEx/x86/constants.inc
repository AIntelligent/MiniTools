;;
;; constants.inc 
;;
;; Author:
;;       Kartal, Hakan Emre <hek@nula.com.tr>
;;
;; Copyright (c) 2024 Kartal, Hakan Emre
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.
;; 
IFNDEF __CONSTANTS_INC__
__CONSTANTS_INC__ equ <1>

.const 

LF 									equ 					(0Ah)
CR 									equ					(0Dh)
EOF 									equ					(1Ah)
LFCR									equ 					(LF * 100h + CR)
CRLF									equ 					(CR * 100h + LF)
TAB									equ					(09h)

MAXIMUM_THREAD_COUNT 			equ					(MAXIMUM_WAIT_OBJECTS)

KILOBYTE_FACTOR					equ					(1024)
MEGABYTE_FACTOR					equ					(KILOBYTE_FACTOR * 1024)

MAXIMUM_BUFFER_LENGTH			equ 					(1 * MEGABYTE_FACTOR)
MAXIMUM_THREAD_BLOCK_LENGTH 	equ 					(MAXIMUM_THREAD_COUNT * MAXIMUM_BUFFER_LENGTH)

DEFAULT_OUTPUT_STRING_LENGTH	equ 					(200h)

MAXIMUM_MODULE_NAME_LENGTH		equ					(12)

ARG_IS_HELP							equ					(-1)
ARG_IS_FILE							equ					(-2)

__DEBUG_STOP__						equ 					<int 3>

ENDIF
