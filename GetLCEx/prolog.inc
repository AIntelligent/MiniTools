;;
;; prolog.inc
;;
;; Author:
;;       Hakan E. Kartal <hek@nula.com.tr>
;;
;; Copyright (c) 2024 Hakan E. Kartal
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
IFNDEF __PROLOG_INC__
__PROLOG_INC__ equ <1>

			include		<..\include\windows.inc>
			include 	  	<..\include\kernel32.inc>
			include     <..\include\user32.inc>
			include 		<..\include\shell32.inc>
			include 		<..\include\shlwapi.inc>
			
			include 		<constants.inc>
			include 		<types.inc>
			include 		<defs.inc>
			include 		<quad_int.inc>
			include 		<file_context.inc>
			include 		<counter_context.inc>

			includelib 	<..\lib\kernel32.lib>
			includelib  <..\lib\user32.lib>
			includelib	<..\lib\shell32.lib>
			includelib 	<..\lib\shlwapi.lib>
			
ENDIF