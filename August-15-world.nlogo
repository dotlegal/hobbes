extensions [table matrix csv]   ;; NETLOGO EXTENSIONS IN USE
;---------------------
__includes   ["---data.nls"]                 ;; .nls FILES WITH SOURCE CODE "OBJECTS"

;2345678901234567890123456789012345678901234567890123456789012345678901234567890
;---------------------
globals [
;;;;;;;;;;;;;;;;;;;;;;      GLOBAL VARIABLES DEFINED IN THE INTERFACE
; xmax root-shft r-zero d-gap incutime d-rate
; p1-begin p1-end d-rate1 d-rate2 FtC-begin FtC-end

;;;;;;;;;;;;;;;;;;;;;;      GLOBAL VARIABLES DEFINED IN THE SOURCE

  dates observations table first-obs last-obs parms drate2
  world-i  PRC-i  USA-i  F-i  UK-i  NL-i  BR-i  ;; weekly accumulated cases
  world-d  PRC-d  USA-d  F-d  UK-d  NL-d  BR-d  ;; weekly accumulated deaths
  world-di PRC-di USA-di F-di UK-di NL-di BR-di ;; weekly new cases
  world-dd PRC-dd USA-dd F-dd UK-dd NL-dd BR-dd ;; weekly new death

  world-diff PRC-diff USA-diff F-diff UK-diff NL-diff BR-diff
  world-diffi PRC-diffi USA-diffi F-diffi UK-diffi NL-diffi BR-diffi

  c-d c-i d-d d-i m-s m-i m-r m-d
  popsizes d-rate1 d-rate2 numbers
  ;------------------------------      workbench globals
  td td- base
]
;;;;;;;;;;;;;;;;;;;;;;      DO SETUP

to setup
  clear-all reset-ticks
  set popsizes [7781173000 1393000000 328200000 67869798  ;;@@@@@@@@@@@@@@@@@@@@
                65263122   17430955   212574666]          ;;@@@@@@@@@@@@@@@@@@@@
  get-data
  create-model-data
  set d-rate1 precision (100 * (last c-d / last c-i)) 2
  set d-rate2 (100 * (last c-d / item 0 popsizes)) ;; @@@@@@@@@@@@@@
end

;2345678901234567890123456789012345678901234567890123456789012345678901234567890
;;;;;;;;;;;;;;;;;;;;;;      DO GO

;---------------------
to go
  if ticks >= xmax [print-numbers stop]
  tick
end
;---------------------
to create-model-data  ;; model several partitions with R0, root-shft, d-gap end incub
                      ;; m-d deaths (cumulative)    = c-d for the moment
                      ;; m-s sick people (actual)   =
                      ;; m-s(i-1) + c-i(i) - c-i(i-d-gap) - d-d(i)
                      ;; m-r recovered (cumulative) =
                      ;; m-r(i-1) + c-i(i) - c-i(i-d-gap)
                      ;; m-i infected (cumulative)   = c-i for the moment
  set m-i [0] set m-r [0] set m-s [0] set m-d [0]
  let ccc 0 set numbers [0]
  let cc 0 let score 1 let LASTONE 0 let BEFORELAST 0
  ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  repeat xmax [ let ds 0 set base 0
    ;--- now m-d
    let NEW LASTONE - BEFORELAST
    set SCORE  SCORE + R-zero * NEW
    set BEFORELAST LASTONE set LASTONE SCORE
    set m-d lput (precision SCORE 0) m-d
    ;--- now m-s
    ifelse ccc < ( d-gap + incutime ) or ccc > xmax - 1 [set m-s lput 0 m-s]
        [ set ds ((item (ccc) c-i) - (item (ccc - d-gap - incutime) c-i)  - (item (ccc) d-d))
          set m-s lput ds m-s]
    ;--- now m-r ()
    ifelse ccc < d-gap [set m-r lput 0 m-r]
      [ set base base + item (ccc - d-gap) c-i  set m-r lput base m-r]

    set ccc ccc + 1
    set numbers lput ccc numbers
  ]
  ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  handle-rootshft
end

to handle-rootshft
   if root-shft < 0 [ repeat abs root-shft
    [ set m-d but-first m-d set m-d lput 0 m-d ] ]
  if root-shft > 0 [ repeat root-shft
   [ set m-d fput 0 m-d set m-d but-last m-d ] ]
end
;---------------------
to print-numbers                   ;; matrix:submatrix matrix r1 c1 r2 c2
  output-type  "  Observed data for jurisdictions: World, PRC, USA, France, UK, Netherlands and Brazil\n\n"
;  if jurisdiction = "USA"         [output-print "USA"]
;  if jurisdiction = "PRC"         [output-print "PRC"]
;  if jurisdiction = "Netherlands" [output-print "Netherlands"]
;  if jurisdiction = "France"      [output-print "Frans"]
;  if jurisdiction = "Global"      [output-print "Global"]
;  if jurisdiction = "UK"          [output-print "UK"]
;  if jurisdiction = "Brazil"      [output-print "Brazil"]

 output-type  " Wk no.  date    world-i world-d prc-i prc-d    USA-i   USA-d      F-i     F-d "
 output-type  "  UK-i   UK-d    NL-i   NL-d   BR-i   BR-d\n" ;;@@@@@@@@@@@
 set observations  ( list numbers dates  world-i world-d prc-i prc-d  USA-i USA-d F-i F-d   UK-i UK-d NL-i NL-d   BR-i BR-d)   ;;@@@@@@@@@@@

    set table matrix:from-column-list observations
    output-print matrix:pretty-print-text table
end
@#$#@#$#@
GRAPHICS-WINDOW
198
189
337
259
-1
-1
1.0
1
20
1
1
1
0
1
1
1
0
130
0
60
0
0
1
ticks
30.0

OUTPUT
9
789
1075
1341
13

TEXTBOX
56
328
79
346
330
11
0.0
1

BUTTON
985
57
1077
90
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
985
93
1078
161
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
986
236
1078
269
R-zero
R-zero
0
4.5
3.85
0.01
1
NIL
HORIZONTAL

CHOOSER
984
10
1076
55
Jurisdiction
Jurisdiction
"Global" "PRC" "USA" "UK" "France" "Netherlands" "Brazil"
0

SLIDER
986
199
1078
232
xmax
xmax
0
39
33.0
1
1
NIL
HORIZONTAL

SLIDER
986
164
1078
197
root-shft
root-shft
-40
40
0.0
1
1
NIL
HORIZONTAL

SLIDER
986
272
1078
305
d-Gap
d-Gap
0
23
3.0
1
1
NIL
HORIZONTAL

PLOT
8
10
491
341
Graph 1: A wider look
week 0 - week xmax
# cases
0.0
34.0
0.0
2.25E7
false
false
"" ""
PENS
"raster" 1.0 0 -3026479 true "" "if  ticks = 5 or ticks = 15 or ticks = 20\n[ plot-pen-up plotxy ticks 0 \n  plot-pen-down plotxy ticks 111110000]"
"dead" 1.0 0 -16777216 true "" "ifelse ticks > root-shft and ticks <= xmax  \n[plot-pen-down plot item (ticks)  c-d][plot-pen-up plot 0]"
"infected" 1.0 0 -16777216 true "" "ifelse ticks > root-shft and ticks <= xmax  \n[plot-pen-down plot item (ticks) c-i][plot-pen-up plot 0]"
"model" 1.0 0 -5987164 true "" "ifelse ticks > root-shft and ticks < (xmax) \nand item ticks m-d < 7000000000\n[plot-pen-down plot item (ticks) m-d][plot-pen-up plot 0]"
"sick" 1.0 0 -5298144 true "" "ifelse ticks > root-shft and ticks <= xmax - 1  \n[plot-pen-down plot item (ticks) m-s][plot-pen-up plot 0]"
"recovered" 1.0 0 -5298144 true "" "ifelse ticks > root-shft and ticks <= xmax - 1  \n[plot-pen-down plot abs item (ticks) m-r][plot-pen-up plot 0]"

SLIDER
986
307
1078
340
incutime
incutime
0
14
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
417
184
477
215
Recovered\n(modeled)
11
0.0
0

TEXTBOX
405
294
467
322
   Deaths\n (observed)
11
0.0
0

TEXTBOX
409
90
473
118
   Infected\n (observed)
11
0.0
0

TEXTBOX
412
248
463
278
     Sick\n(modeled)
11
0.0
0

TEXTBOX
65
260
166
302
Wk 0 (29/12/19) \nfirst victims \nin Wuhan\n
11
0.0
0

PLOT
497
10
982
341
Graph 2: New Cases/30 & New Deaths (red) per week
weeks
people 
0.0
34.0
0.0
65000.0
false
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "ifelse ticks > 0 and ticks <= (xmax) \n[plot-pen-down plot item ticks d-i / 30] [plot-pen-up plot 0]"
"pen-1" 1.0 0 -3026479 true "" "if ticks = 5 or ticks = 15 or ticks = 20\n[plot-pen-up plotxy ticks 0 plot-pen-down plotxy ticks 5000000]"
"pen-2" 1.0 0 -5298144 true "" "ifelse ticks > 0 and ticks <= (xmax) \n[plot-pen-down plot item ticks d-d ] \n[plot-pen-up plot 0]"

TEXTBOX
237
173
259
201
wk\n15
11
0.0
0

TEXTBOX
725
280
743
308
wk\n15
11
0.0
0

TEXTBOX
593
280
614
308
wk\n 5
11
0.0
0

TEXTBOX
110
313
125
331
o
15
0.0
1

TEXTBOX
107
175
129
203
wk\n 5
11
0.0
0

TEXTBOX
184
234
243
263
Deaths\n(modeled)
11
0.0
0

TEXTBOX
790
277
809
305
wk\n20
11
0.0
0

TEXTBOX
302
173
323
201
wk\n20
11
0.0
0

MONITOR
544
163
602
208
d-rate2
d-rate2 * 10000
0
1
11

MONITOR
543
32
677
113
 Jurisdiction
jurisdiction
0
1
20

MONITOR
123
32
180
77
  R0
r-zero
2
1
11

MONITOR
56
78
112
123
deaths
item xmax c-d
0
1
11

MONITOR
55
32
121
77
time stamp
item xmax dates
0
1
11

MONITOR
544
115
649
160
Population
item 0 popsizes
17
1
11

PLOT
8
349
1079
781
Comparing COVID-19 deaths per jurisdiction per week, harmonized for population sizes (deaths per 1.000.000 after week x)
weeks
d-rate2
0.0
34.0
0.0
0.0
true
true
"" ""
PENS
"world" 1.0 0 -16777216 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks world-d / item 0 popsizes\n    plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"USA" 1.0 0 -16777216 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks USA-d / item 2 popsizes\n     plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"NL" 1.0 0 -2674135 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks NL-d / item 5 popsizes\n     plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"UK" 1.0 0 -955883 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks UK-d / item 4 popsizes\n    plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"France" 1.0 0 -6459832 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks F-d / item 3 popsizes\n     plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"BR" 1.0 0 -4079321 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks BR-d / item 6 popsizes\n    plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"
"PRC" 1.0 0 -10899396 true "" "if ticks > 0 and ticks <= xmax \n  [ set drate2 item ticks PRC-d / item 1 popsizes\n    plot precision (drate2 * 1000000) 2]\nif ticks = xmax [show precision (drate2 * 1000000) 2]"

TEXTBOX
41
439
286
610
Ranking\t Jurisdiction  No. of deaths \n                           per million\n  1\t        PRC\t                3\n  2\t       The world        98          \n  3        NL\t               354\n  4\t        France          448\n  5        Brazil            501\n  6        USA\t             523\n  7\t        UK              \t 634\n
15
0.0
1

TEXTBOX
901
382
932
404
 UK 
15
0.0
0

TEXTBOX
891
472
929
491
 USA 
15
0.0
0

TEXTBOX
698
497
755
516
 France 
15
0.0
0

TEXTBOX
932
545
956
564
 NL 
15
0.0
0

TEXTBOX
859
519
906
538
 Brazil 
15
0.0
0

TEXTBOX
836
707
914
726
 The World 
15
0.0
0

TEXTBOX
904
749
950
768
 China
15
0.0
0

TEXTBOX
44
697
148
753
Wk 0 is set on\nDecember 29, 2020\nwith first contami-\nnations in Wuahan
11
0.0
1

TEXTBOX
422
378
572
439
Around wk 15 (April 10 2020)\nthe pandemic peaked after  \nmost jurisdictions had taken\nmeasurements
11
0.0
1

TEXTBOX
288
590
408
730
By week 10 \nMarch 6, 2020)\nChina has its \nlocal epidemic \nunder control, \nthe pandemic \nspreads worldwide, \nnumbers still \nmanagable so \nit seems
11
0.0
1

MONITOR
113
78
180
123
Cases
item xmax c-i
17
1
11

MONITOR
35
370
102
415
time stamp
item xmax dates
0
1
11

TEXTBOX
263
704
279
760
wk\n10\n  |\n  |
11
0.0
1

TEXTBOX
387
368
402
424
  |\n  |\nwk\n15
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

An explorative simple model for the COVID-19 pandemic. It is the first example algorithm in the Schmidt on sense, law and complexity blog (dotlegal.nl). The model is compartmented in three dimensions: 
1. species (like Susceptible, Infective, Resistent, Dead/borm) 
2. consistencies (like [R0.0=1.8, R0.1=1, R0.2=0.8]) 
3. patches (like addresses, for defining neighborhoods)
   

## HOW IT WORKS



## HOW TO USE IT



## THINGS TO NOTICE


## THINGS TO TRY



## VARIATE THE MODELS


## NETLOGO FEATURES



## RELATED MODELS



## CREDITS AND REFERENCES
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
