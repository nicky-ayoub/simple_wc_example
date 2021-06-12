TEST
.MODEL nbjt NPN
.MODEL pbjt PNP
.MODEL nmos NMOS
.MODEL pmos PMOS
.MODEL njfet NJF
.MODEL pjfet PJF
.MODEL cap C
.MODEL res R
.MODEL diode D
.INCLUDE 'n73d.model'

* test devices
R1 Rnode1 Rnode2 100
C1 1 2 cap
L1 42 69 1UH
D1 3 0 diode 3 IC=0.2
Q1 3 2 5 nbjt AREA=1.5 AREAB=2.5 AREAC=3.0 IC=0.6
*J1 7 2 3 njfet
M3 24 2 0 20 PC1_PM1_DU2

* test sources
I1 8 7 I=1A
V1 1 0 AC=10V

L1 42 69 1U
L1 42 69 1m
.END
* C
