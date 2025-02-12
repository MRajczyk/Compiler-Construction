program example(input, output);
var x, y: integer;
var g,h:real;

function gcd(a, b: integer):integer;
begin
  if b=0 then 
    gcd:=a
  else 
    gcd:=gcd(b, a mod b)
end;


function sub1(a, b: integer):integer;
begin
   sub1 := a - b
end;

function sub2(b, a: integer):integer;
begin
   sub2 := a - b
end;


begin
  read(x, y);
  write(gcd(sub1(24,6), sub2(1, 10)))
end.
