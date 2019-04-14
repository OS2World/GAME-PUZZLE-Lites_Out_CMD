program litesout;

{$DEFINE RANDINIT}       { To implement Max Yugaldin's always-solvable    }
                         { init procedure, remove this line and recompile }

{$IFNDEF VIRTUALPASCAL}  { DOS version: Use Turbo Pascal 6.0+ to compile }

uses
 crt,drivers;

{$ELSE}                  { OS/2 version: use Virtual Pascal }

uses
 crt,drivers,os2base;

{$ENDIF}

const
 xelems=5;
 yelems=5;
 xwide=10;
 ywide=4;
 stoffset=15;

 toomany=500;
 deltime=3000;

 restx1=-1;
 restx2=0;
 resty1=0;
 resty2=(yelems div 2)-1;
 colx1=-1;
 colx2=0;
 coly1=(yelems div 2)+1;
 coly2=yelems-1;
 quitx1=xelems;
 quitx2=10;
 quity1=2;
 quity2=yelems-3;

 qwide=xwide-3;
 qdeep=ywide-1;
 xgap=(80-(xelems*xwide)) div 2;
 ygap=(25-(yelems*ywide)) div 2+1;

 plotit:array[false..true] of string[qwide]=('       ','ллллллл');
 games:integer=-1;
 wins:word=0;

 version='1.01';

var
 lites:array[0..xelems-1,0..yelems-1] of boolean;
 x,y,z,q:integer;
 lights:byte;

 clicks:word;
 totclicks:longint;
 blockcol:byte;

 c:char;

{$IFNDEF VIRTUALPASCAL}

procedure slice; assembler;
 asm
            int $28
 end;

{$ELSE}

procedure slice;
 var
  foo:word;
 begin
  foo:=dossleep(10)
 end;

{$ENDIF}

function mousecheck:boolean;
 begin
  if buttoncount<>0 then
   begin
    initvideo;
    initevents;
    mousecheck:=true
   end
  else mousecheck:=false
 end;

function mouseg:boolean;
 var
  mvent:tevent;
 begin
  getmouseevent(mvent);
  mouseg:=(mousebuttons=mbleftbutton)
 end;

procedure display(x,y:integer);
 begin
  textcolor(blockcol);
  for z:=1 to qdeep do
   begin
    gotoxy(x*xwide+xgap+1,y*ywide+ygap+z);
    write(plotit[lites[x,y]])
   end
 end;

procedure toggle(x,y:integer);
 begin
  if ((x>=0) and (x<xelems)) and ((y>=0) and (y<yelems)) then
   begin
    lites[x,y]:=not(lites[x,y]);
    display(x,y)
   end
 end;

procedure hitone(x,y:integer);
 begin  
  toggle(x,y);
  toggle(x-1,y);
  toggle(x,y-1);
  toggle(x,y+1);
  toggle(x+1,y)
 end;

procedure refresh;
 begin
  for x:=0 to xelems-1 do
   for y:=0 to yelems-1 do
    display(x,y)
 end;

function victory:boolean;
 var
  none:boolean;
 begin
  none:=true;
  lights:=0;
  for x:=0 to xelems-1 do
   for y:=0 to yelems-1 do
    if lites[x,y] then
     begin
      inc(lights);
      none:=false
     end;
  victory:=none
 end;

function within(a,b,c,d:integer):boolean;
 begin
  within:=((x>=a) and (x<=b)) and ((y>=c) and (y<=d))
 end;

function inrange:boolean;
 begin
  inrange:=within(0,xelems-1,0,yelems-1)
 end;

{$IFNDEF RANDINIT}

procedure init;  { Solvable init --  contributed by      }
                 { Max Yugaldin <max@landau.niif.spb.su> }
const difficulty=25;
 begin
   for x:=0 to xelems-1 do 
     for y:=0 to yelems-1 do
       lites[x,y]:=false;
   for x:=1 to difficulty do hitone(random(xelems),random(yelems));
   lights:=0;
   for x:=0 to xelems-1 do
     for y:=0 to yelems-1 do
       if lites[x,y] then inc(lights);
 end;

{$ELSE}

procedure init;  { Junk init -- randomize }
 begin
  lights:=0;
  for x:=0 to xelems-1 do
   for y:=0 to yelems-1 do
    begin
     lites[x,y]:=(random(2)=1);
     if lites[x,y] then inc(lights)
    end
 end;

{$ENDIF}

procedure box;
 begin
  gotoxy(xgap-1,ygap);
  write('Щ');
  for x:=1 to xelems do
   begin
    for y:=1 to xwide-1 do write('Э');
    if x<>xelems then write('б')
   end;
  write('Л');
  for x:=1 to yelems do
   begin
    for y:=1 to ywide-1 do
     for z:=0 to xelems do
      begin
       gotoxy(xgap+z*xwide-1,ygap+(x-1)*ywide+y);
       if (z=0) or (z=xelems) then write('К')
       else write('Г')
      end;
    if x<>yelems then
     begin
      gotoxy(xgap-1,ygap+x*ywide);
      write('Ч');
      for z:=1 to xelems do
       begin
        gotoxy(xgap+(z-1)*xwide,ygap+x*ywide);
        for q:=1 to xwide-1 do write('Ф');
        if z<>xelems then write('Х')
        else write('Ж')
       end
     end
   end;
  gotoxy(xgap-1,ygap+yelems*ywide);
  write('Ш');
  for x:=1 to xelems do
   begin
    for y:=1 to xwide-1 do write('Э');
    if x<>xelems then write('Я')
   end;
  write('М')
 end;

procedure spectext;
 begin
  gotoxy((xgap-7) div 2,6);
  write('Restart');
  gotoxy((xgap-6) div 2,18);
  write('Color');
  gotoxy((xgap-6) div 2,19);
  write('Change');
  gotoxy(xgap+xelems*xwide+((xgap-4) div 2),12);
  write('Quit')
 end;

procedure statline;
 begin
  gotoxy(stoffset,ygap+yelems*ywide+2);
  write('Clicks:        Lights:      Games:       Wins:')
 end;

procedure statup;
 begin
  textcolor(7);
  gotoxy(stoffset+8,ygap+yelems*ywide+2);
  write(clicks:5);
  gotoxy(stoffset+23,ygap+yelems*ywide+2);
  write(lights:3)
 end;

procedure gameup;
 begin
  textcolor(7);
  gotoxy(stoffset+35,ygap+yelems*ywide+2);
  write(games:3);
  gotoxy(stoffset+46,ygap+yelems*ywide+2);
  write(wins:3)
 end;

procedure restart;
 begin
  inc(games);
  gameup;
  blockcol:=random(15)+1;
  clicks:=0;
  init;
  refresh
 end;

procedure nextcol;
 begin
  inc(blockcol);
  if blockcol=16 then blockcol:=1;
  refresh
 end;

function ontarget:boolean;
 begin
  ontarget:=true;
  if not inrange then
   if within(restx1,restx2,resty1,resty2) then restart
   else if within(colx1,colx2,coly1,coly2) then nextcol
        else if within(quitx1,quitx2,quity1,quity2) then ontarget:=false
 end;

procedure sinit;
 begin
  clrscr;
  write('      Lights Out! v'+version+
   '  written by William McBrine  wmcbrine@clark.net');
  box;
  spectext;
  statline
 end;

procedure warn;
 begin
  gotoxy(1,ygap+yelems*ywide+2);
  textcolor(7);
  writeln;
  writeln;
  writeln('Don''t you think you should rest your arm now?'#7);
  delay(deltime);
  sinit;
  refresh;
  statup;
  gameup
 end;

procedure main;
 begin
  restart;
  showmouse;
  repeat
   statup;
   while not(mouseg) do slice;
   repeat until not(mouseg);
   x:=mousewhere.x-xgap+1;
   if x>=0 then x:=x div xwide
   else x:=-1;
   y:=mousewhere.y-ygap+1;
   if y>=0 then y:=y div ywide
   else y:=-1;
   if inrange then 
    begin
     inc(clicks);
     inc(totclicks);
     hidemouse;
     hitone(x,y);
     showmouse;
     if (totclicks>0) and ((totclicks mod toomany)=0) then warn
    end
  until not(ontarget) or victory
 end;

begin
 randomize;
 if not(mousecheck) then
  begin
   writeln('Sorry, this program requires a mouse.');
   halt(1)
  end
 else
 repeat
  c:='N';
  sinit;
  main;
  hidemouse;
  statup;
  if victory then
   begin
    inc(wins);
    gotoxy(1,ygap+yelems*ywide+2);
    textcolor(7);
    writeln;
    writeln;
    writeln('Congratulations! You solved it!!'#7);
    write('Play again? (Y/n) ');
    while not keypressed do slice;
    c:=upcase(readkey)
   end
 until c='N';
 donevideo
end.
