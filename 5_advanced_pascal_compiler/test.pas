program example(input, output);
var x, y, z: integer;

begin
  read(x);
  x:=1 + 2 * 3 -4/(5+6);
  y:=1+x*(2 - 1 div 3);
  z:=y mod 3;
  write(x);
  write(y);
  write(z)
end.