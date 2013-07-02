package impl;
import haxe.macro.Expr;
import haxe.macro.Context;

//using Lambda;

class IntDivision
{
	
    inline static function abs(x : Int) {return ((x) < 0 ? ~(x)+1 : (x));}

    private static inline function posIntDiv(num : Int, denom : Int) : Int
    {
		var a : Int=0;
		var b : Int=0;
		var i : Int = 31; // TODO: CAREFUL: works only on int=32-bit machine!
		/* Work from leftmost to rightmost bit in numerator */
		while (i >= 0)
		{
			/* appends one bit from numerator to a */
			a = (a << 1) + ((num & (1 << i)) >> i);
			b = b << 1;
			if (a >= denom)
			{
				a -= denom;
				b++;
			}
			i--;
		}
		return b;
    }
    
    public static inline function intDivDynamic(a : Int, b : Int) : Int
    {
        var dividend = abs(a);
        var divisor = abs(b);
        
        if (divisor==0) return 0;
        
        else if (divisor > dividend) 
        {
            return 0;
        }

        else if (divisor == dividend) 
        {
            return 1;
        }
        
        else
        {
            var quotient = posIntDiv(dividend,divisor);
            if (a<0) { if (b>0) return ~quotient+1; else return quotient; }
            else { if (b<0) return ~quotient+1; else return quotient; }
        }
    }
	
	macro public static function intDiv(a : Expr, b : Expr) : Expr
	{
		
		var constA = { val : 0, isConst : false };
		var constB = { val : 0, isConst : false };
		
		switch(a.expr)
		{
			case EConst(c):
			{
				switch(c)
				{
					case CInt(i):
					{
						constA.val = Std.parseInt(i);
						constA.isConst = true;
					}
					case CIdent(name):
					{
						var fields = Context.getLocalClass().get().statics.get();
						var myField = fields.filter( function(f) { return f.name == name; }).shift();
						if (myField != null)
						{
							if (myField.expr() == null) throw 'Field $name had no initialization value...';
							var expr = Context.getTypedExpr(myField.expr());
							var fieldVal = switch(expr.expr)
							{
								case EConst(CInt(v)): Std.parseInt(v);
								case _: throw 'Was expecting $name to be initialized as an Int';
							}
							constA.val = fieldVal;
							constA.isConst = true;
						}
						else
						{
							constA.isConst = false;
						}
					}
					default:
				}
			}
			default:
        };
		
		switch(b.expr)
		{
			case EConst(c):
			{
				switch(c)
				{
					case CInt(i):
					{
						constB.val = Std.parseInt(i);
						constB.isConst = true;
					}
					case CIdent(name):
					{
						var fields = Context.getLocalClass().get().statics.get();
						var myField = fields.filter( function(f) { return f.name == name; }).shift();
						if (myField != null)
						{
							if (myField.expr() == null) throw 'Field $name had no initialization value...';
							var expr = Context.getTypedExpr(myField.expr());
							var fieldVal = switch(expr.expr)
							{
								case EConst(CInt(v)): Std.parseInt(v);
								case _: throw 'Was expecting $name to be initialized as an Int';
							}
							constB.val = fieldVal;
							constB.isConst = true;
						}
						else
						{
							constB.isConst = false;
						}
					}
					default:
				}
			}
			default:
        };
		
		if (constA.isConst && constB.isConst)
		{
			var returnVal : Int = cast(constA.val / constB.val);
			var e : Expr = {
				expr : EConst(CInt(Std.string(returnVal))), 
				pos : Context.currentPos()
			};
			return e;
		}
		else
		{
			return macro IntDivision.intDivDynamic($a, $b);
		}
		
	}
}
