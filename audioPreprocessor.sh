#!/bin/bash
reverbType="$1"
#Depends on http://sourceforge.net/p/sox/patches/92/ .

#The MIT License (MIT)
#
#Copyright (c) 2014 mirage335
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

#Necessary preprocessing, rate conversion and DC bias removal.
processingChain="rate -v -I -s 44.1k ladspa -r cmt hpf 2"

#Set reverberation (environment simulation) parameters.
case "$reverbType" in
ClearReverb)
	processingChain="$processingChain ladspa tap_reverb 1900 -2 -14 1 1 1 1 26"
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
AfterBurnLongReverb)
	processingChain="$processingChain ladspa tap_reverb 4800 -4 -10 1 1 1 1 1"
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
AmbienceThickHDReverb)
	processingChain="$processingChain ladspa tap_reverb 1200 -11 -14 1 1 1 1 4"
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
AmbienceReverb)
	processingChain="$processingChain ladspa tap_reverb 1100 -8 -11 1 1 1 1 2"
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
SmallRoomReverb)
	processingChain="$processingChain ladspa tap_reverb 1900 -6 -9 1 1 1 1 26"
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
NullReverb)
	echo -e '\E[1;32;46m'" $reverbType "'\E[0m'
	;;
*)
	echo -e '\E[1;33;41m No reverbType found, first parameter: [ClearReverb|AfterBurnLongReverb|AmbienceThickHDReverb|AmbienceReverb|SmallRoomReverb|NullReverb] \E[0m'
	exit
	;;
esac

#Post-reverb stereo channel mixing, as would normally occur in a real room..
processingChain="$processingChain ladspa bs2b 650 9.5"

#Subtle effect, TubeWarmpth. Seems to slightly ease harmonic distortion.
processingChain="$processingChain ladspa -r tap_tubewarmth 2.5 10"

#Headphone frequency correction.
processingChain="$processingChain ladspa -r single_para_1203 6 16000 4 ladspa -r single_para_1203 3 17000 2 ladspa -r single_para_1203 -3 250 1 ladspa -r single_para_1203 -4 1250 2 ladspa -r single_para_1203 -13 4250 0.65 ladspa -r single_para_1203 -10 7650 0.3 ladspa -r single_para_1203 -3 11250 0.65"

echo ''
echo -e '\E[1;32;46m'""$processingChain""'\E[0m'
echo ''

find . -type f -regextype posix-extended -regex '.*\.ogg|.*\.mp3|.*\.flac|.*\.wav|.*\.m4a|.*\.wma|.*\.wv|.*\.swa|.*\.aac|.*\.ac3' -exec sox --multi-threaded --buffer 131072 {} -C 8 {}-"$reverbType"-256kb.ogg $processingChain \; -exec rm {} \;