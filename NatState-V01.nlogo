;__includes [ ]
extensions [matrix]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          BREEDS, GLOBALS & SETUP                            ;;
;;;;;;;;;;;;;;;nb;;;;;;; ! # $ % & _ ? -> 0 can be set as variables ;;;;;;;;;;;;;

breed [inds ind]
;;;;;;;;;;;;;;;;;;;;;;; i n d i v i d u a l s  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [members member]             ;; celebrate, maintain identity
breed [civilians civilian]         ;; may (be) designate(d) sovereign
breed [consumers consumer]         ;; trade/produce goods/services for prices
breed [realists realist]           ;; has covictions, imvestigates for evidence
inds-own [rural? wealth memberships civilianships consumerships convictions track]
members-own   [of-community   status    track]
civilians-own [of-institution security  track]
consumers-own [of-enterprise  capital   track]
realists-own  [of-discipline  knowledge track]
;;;;;;;;;;;;;;;;;;;;;;; s t r u c t u r e s    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [communities community]      ;; provide & operate status
breed [institutions institution]   ;; provide & operate security
breed [enterprises enterprise]     ;; provide & operate capital
breed [disciplines discipline]     ;; provide & operate knowledge
communities-own  [wisdom wealth purity track]
institutions-own [wisdom wealth purity track]
enterprises-own  [wisdom wealth purity track]
disciplines-own  [wisdom wealth purity track]

globals [
  parameters
  current-phase xcount ycount
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;            consider ...            ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;  clear-all;  reset-ticks;  set current-phase 1;  showparameters
  ;  store parameters ; store networks; store run; make-inds
  ;  make-members ;  make-civilians ;  make-consumers ;  make-realists
  ;  make-communities ;  make-institutions ;  make-enterprises ;  make-disciplines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;            consider ...            ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup clear-all
  set #urbans #rurals
  output-print "(setup)"
  output-type "Press 'clear' to start a new session ... "
  output-type "\nPress 'resume' to resume working with a logged session"
end
 to resume output-type "\n\nThe 'resume' function is not yet implemented ..." end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;       create agent networks       ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to make-the-net ;  ;;;; setup for growing a preferential-attached network of inds
  set-default-shape inds "circle"   let #inds (#rurals + #urbans)
  make-urban-node nobody make-urban-node ind 0 ;;;; start with two nodes
  while [count inds <= #inds] [                ;;;; grow the net one by one
    make-urban-node find-partner ask links [set color grey]
    layout-urbans ]
  set #rurals count inds with [rural?]
  set #urbans count inds with [not rural?]
end
to make-rurals
  ask inds with [color != black][ find-new-spot ]
  setup-spatially-clustered-network
end

to setup-spatially-clustered-network
  set #rurals count inds with [rural? = true]
  let num-links (max-degree * #rurals) / 2
  while [count links < num-links ]
  [ ask one-of inds with [rural? = true]
    [ let choice (min-one-of
        (other inds with [rural? = true and not link-neighbor? myself])
        [distance myself]) if choice != nobody [ create-link-with choice ]
    ] ]
end

to-report find-partner report [one-of both-ends] of one-of links end
to make-urban-node [old-node]
  create-inds 1 [ set color grey set size 0.7 set rural? true
    set wealth [] set memberships [] set civilianships [] set consumerships []
    set convictions [] set track [] if old-node != nobody [
      create-link-with old-node [ set color grey ] ask old-node [
        ifelse count link-neighbors > urbcrit [
          set color red set size 1 ask link-neighbors [
            set color black set rural? false set size 0.7
            move-to old-node forward 0 ask link-neighbors [
              set color black set rural? false set size 0.7
              move-to old-node forward 0 ]
   ] ] [set size 0.7] ] ] ]
end

to do-clear clear-all reset-ticks end

to invert-colors
  ask inds with [color = grey][set color green]
  ask inds[ ifelse color = green
      [set color black]
      [set color green]]
end

to make-a-chessboard
  set xcount 0 set ycount 0
  repeat 64 [
    repeat 64 [ ask patch (xcount - 31) (ycount - 31)
                [ifelse (2 mod (xcount + ycount + 1000) = 0) [set color 5] [set color 4]
        set ycount ycount + 1]]
    set xcount xcount + 1 set ycount 0]
end

to plot-degrees-urbans
                                     ;;  replace reset-ticks with setup-plots update-plots and replace tick with update-plots.
  let urbans []
  ask inds with [not rural?] [ set urbans lput count (link-neighbors) urbans ]
  set-plot-x-range 1 (max urbans + 1)  ;; + 1 to make room for the width of the last bar
  histogram urbans

  wait 10

  let rurals []
  ask inds with [rural?] [ set rurals lput count (link-neighbors) rurals ]
  set-plot-x-range 1 (max rurals + 1)  ;; + 1 to make room for the width of the last bar
  histogram rurals



;  let urbaninds inds with [not rural?]
;  let max-degreex max [count link-neighbors] of urbaninds
;  plot-pen-reset  ;; erase what we plotted before
;  set-plot-x-range 1 (max-degreex + 1)  ;; + 1 to make room for the width of the last bar
;  histogram [count link-neighbors] of urbaninds
end
to go

end

;;;;;;;;;;;;;;;;;;;;;;; s t r u c t u r e s    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to showparameters
  set parameters (list
 (list "#inds      " (#rurals + #urbans) " individuals" )
 (list "#communities  " #communities " networks that provide & operate status" )
 (list "#institutions " #institutions " networks that provide & operate security")
 (list "#enterprises  " #enterprises " networks that provide & operate capital")
 (list "#disciplines  " #disciplines " networks that provide & operate knowledge")
 (list "%extreme     "  %extreme " the climate for dogmatics" )
 (list "%enforce     "  %enforce  " the climate for rule enforcement" )
 (list "%laisser     "  %laisser  " the climate for laisser-aller economics")
 (list "%evid-ba     "  %evid-ba " the climate for evidence-based argument"))
  let parms parameters
  output-print ("\n======    These are the parameters of the model   ====== \n")
  foreach parms [output-print first parms set parms but-first parms]
end






;to make-indsV0
;  let parms (list
;  (list "\n=====  Making " #inds
;   "individuals (preferential attachment) ======" ))
;  foreach parms [output-print first parms set parms but-first parms]
;  make-the-net
;  output-type "#urbans " output-type count inds with [not rural?]
;  output-type " #rurals " output-type count inds with [rural?]
;  output-type " No. of hubs " output-print count inds with [count link-neighbors > urbcrit]
;end

to make-members end
to make-civilians end
to make-consumers end
to make-realists end
to make-communities end
to make-institutions end
to make-enterprises end
to make-disciplines end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; o b j e c t s ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report limit-magnitude [number limit] if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]report number end

to layout-urbans
  repeat 3 [ let factor sqrt count inds
    layout-spring inds links (8 / factor) (8 / factor) (1 / factor)]
  display
  let x-offset max [xcor] of inds + min [xcor] of inds
  let y-offset max [ycor] of inds + min [ycor] of inds
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask inds [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end

to find-new-spot
  right random-float 360 forward random-float 10
  if any? other turtles-here [ find-new-spot ] move-to patch-here
end
@#$#@#$#@
GRAPHICS-WINDOW
10
9
631
631
-1
-1
9.7302
1
10
1
1
1
0
0
0
1
-31
31
-31
31
0
0
1
ticks
30.0

SLIDER
695
252
787
285
#rurals
#rurals
0
1024
375.0
64
1
NIL
HORIZONTAL

SLIDER
695
322
787
355
#communities
#communities
1
9
6.0
1
1
NIL
HORIZONTAL

SLIDER
695
357
787
390
#institutions
#institutions
1
9
6.0
1
1
NIL
HORIZONTAL

SLIDER
884
322
986
355
#enterprises
#enterprises
1
9
6.0
1
1
NIL
HORIZONTAL

SLIDER
885
357
987
390
#disciplines
#disciplines
1
9
4.0
1
1
NIL
HORIZONTAL

BUTTON
997
287
1092
321
go
output-print \"the 'go' function is not yet implemented ...\"\nstop
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
790
322
882
355
%extreme
%extreme
10
90
10.0
20
1
NIL
HORIZONTAL

SLIDER
790
357
882
390
%enforce
%enforce
10
90
10.0
20
1
NIL
HORIZONTAL

SLIDER
988
322
1091
355
%laisser
%laisser
10
90
90.0
20
1
NIL
HORIZONTAL

SLIDER
989
358
1091
391
%evid-ba
%evid-ba
10
90
10.0
20
1
NIL
HORIZONTAL

PLOT
635
392
932
631
urban-degrees
NIL
NIL
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"urbans" 1.0 1 -16777216 true "" "let urbans []\n  ask inds with [not rural?] [ set urbans lput count (link-neighbors) urbans ]\n  set-plot-x-range 1 (max urbans + 1)  ;; + 1 to make room for the width of the last bar\n  set urbans but-first urbans histogram urbans\n  \n  "

OUTPUT
634
10
1095
247
11

SLIDER
884
250
976
283
urbcrit
urbcrit
2
32
17.0
1
1
NIL
HORIZONTAL

SLIDER
790
252
882
285
max-degree
max-degree
0
9
5.0
1
1
NIL
HORIZONTAL

BUTTON
636
287
691
320
inds
output-print \"(inds)\"\noutput-type \"creating a network of inds using preferential attach-\"\noutput-type \"\\nment guided by #urbans (yellow), #rurals and urbcrit.\"\noutput-type \"\\n ... this requires time ... Press 'rurals' when done.\"\nmake-the-net
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1114
11
1172
56
We're in
Current-phase
0
1
11

BUTTON
636
252
691
285
clear
do-clear\nask patches [ set pcolor 9 ] \n\n  \n  \n  \n  \n  \n  \noutput-print \"(clear)\\ncleared for setting up the world. Press 'inds'.\"
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
636
322
691
355
rurals
make-rurals layout-urbans layout-urbans\noutput-print \"\\n(rurals)\"\noutput-type \"Transforming the rural part of the network into a \"\noutput-type \"\\nmean-degree network. Use 'invert' \"\noutput-type \"\\nto toggle focus between the urban and the  \"\noutput-type \"\\nrural parts of the net.\"\noutput-type \"\\nUse 'set-hbs' to show the hubs in de urban part\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
790
287
882
320
hubs
hubs
5
100
25.0
5
1
NIL
HORIZONTAL

SLIDER
695
287
787
320
#urbans
#urbans
0
1024
266.0
64
1
NIL
HORIZONTAL

MONITOR
1114
59
1171
104
#inds
count inds
0
1
11

BUTTON
884
286
939
320
set-hbs
ask inds with [not rural? and count link-neighbors >  hubs] \n[set shape \"circle\" set color red set size 1 display]\noutput-print \"\\n(set-hbs)\"\noutput-type \"Colored the hubs red, all \" \noutput-type count inds with [color = red]\noutput-print \" of them. \"\noutput-type \"For degree-distributions try 'plot'.\"
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
636
357
692
390
invert
invert-colors
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
978
250
1034
284
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
1037
250
1092
284
resume
resume
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
940
287
995
320
plot
setup-plots\nupdate-plots
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
934
392
1094
631
rural degrees
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"rurals" 1.0 1 -15575016 true "" "  let rurals []\n  ask inds with [rural?] [ set rurals lput count (link-neighbors) rurals ]\n  set-plot-x-range 1 (max rurals + 1)  ;; + 1 to make room for the width of the last bar\n  histogram rurals\n"

MONITOR
1114
107
1171
152
#links
count links
0
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
