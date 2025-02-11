program example(input, output);
var x, y: integer;
var g,h:real;

function g(a:integer):integer;
begin
 g:=a+12
end;

function f(a:integer):integer;
begin
 f:=a+g(10)
end;

begin
x:=f(f(3));
write(x)
end.
