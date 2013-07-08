package mp4;

/**
 * Copy-pasted from: http://pastebin.com/iq6xBja6
 */

enum UTF {
	_utf8;
	_utf16(be:Bool); //big endian
	_utf32(be:Bool); //big endian
}

typedef UStr  = Array<Int>; //UTF32 (native endian) string
typedef BStr  = UStr; //byte string for input/ouput
typedef WChar = Int;

private class Integer {
	public var i:Int;
	public function new(i:Int) this.i = i
}

class Unicode {
	
	//lexicographical ordering.
	public static inline function compare(a:UStr, b:UStr) {
		var ret = 0;
		var i0 = 0; var i1 = 0;
		while(ret==0) {
			var r0 = if(i0<a.length) a[i0] else null;
			var r1 = if(i1<b.length) b[i1] else null;
			
			if     (r0 != null && r1 == null) ret =  1;
			else if(r1 != null && r0 == null) ret = -1;
			else if(r0 == null && r1 == null) break;
			else {
				ret = r0-r1;
				i0++; i1++;
			}
		}
		return ret;
	}
	
	public static inline function concat(a:UStr, x:UStr) {
		for(i in x) a.push(cast x);
	}
	public static inline function substr(str:UStr, pos:Int, ?cnt:Int = -1) {
		if(cnt==-1) cnt = str.length-pos;
		var ret = new UStr();
		var max = pos+cnt;
		if(max>str.length) max = str.length;
		for(i in pos...max) ret.push(str[i]);
		return ret;
	}
	
	#if neko
		//neko uses a very weird encoding scheme.

		//this is not guaranteed to be correct! but it works for what i've tested and analysed.
		//it is limited to unicode points <= 0xffff though. so doesn't handle full unicode.
		public static function string(str:UStr):String {
			var ret = new StringBuf();
			for(i in str) {
				if(i<0x80) ret.addChar(i);
				else if(i<0xfff) {
					var c0 = i&0x3f;
					i >>>= 6;
					var c1 = i&0x3f;
					
					ret.addChar(0xc0 | c1);
					ret.addChar(0x80 | c0);
				}else {
					var c0 = i&0x3f;
					i >>>= 6;
					var c1 = i&0x3f;
					i >>>= 6;
					var c2 = i&0x1f;
					
					ret.addChar(0xe0 | c2);
					ret.addChar(0x80 | c1);
					ret.addChar(0x80 | c0);
				}
			}
			return ret.toString();
		}
		public static function fromString(str:String):UStr {
			var ret = new UStr();
			var pos = 0;
			while(pos<str.length) {
				var c0 = str.charCodeAt(pos++);
				if((c0&0x80)==0) ret.push(c0);
				else if((c0&0xc0)==0x80) {
					var acc = c0&0x3f;
					acc |= ((c0=str.charCodeAt(pos++))&0x3f)<<6;
					if((c0&0xc0)==0x80)
						acc |= ((c0=str.charCodeAt(pos++))&0x1f)<<12;
					ret.push(acc);
				}else if((c0&0xe0)==0xe0) {
					var acc = (c0&0x1f)<<12;
					acc |= ((str.charCodeAt(pos++))&0x3f)<<6;
					acc |= (str.charCodeAt(pos++))&0x3f;
					ret.push(acc);
				}else if((c0&0xe0)==0xc0) {
					var acc = (c0&0x3f)<<6;
					acc |= (str.charCodeAt(pos++))&0x3f;
					ret.push(acc);
				}else break;
			}
			return ret;
		}
	#elseif flash
		
		//flash uses nice simple wrapped unicode :)
		public static inline function fromString(str:String):UStr {
			var ret = new UStr();
			for(i in 0...str.length) ret.push(str.charCodeAt(i));
			return ret;
		}
		public static inline function string(str:UStr):String {
			var ret = new StringBuf();
			for(i in str) ret.addChar(i);
			return ret.toString();
		}
	
	#end
	
	public static inline function wchar(a:String) return fromString(a)[0]
	
	static inline function neq<T>(a,b) return switch(a) { case b: true; default: false; }

	//stores interpreted utf mode for decode instruction
	//can also be set once to allow 'null' to be passed to encode instructions
	
	public static var utf_mode:UTF;
	public static inline function decode(str:BStr,?mode:UTF):UStr {
		var pos = new Integer(0);
		var ret = null;
		if(mode==null) {
			//determine UTF format if not specified in argument
			mode = utf_mode = bom_decode(str,pos);
			//default to utf8
			if(mode==null) mode = utf_mode = _utf8;
		}else {
			//otherwise read BOM anyways, and if it's not specified doesn't matter.
			var rmode = bom_decode(str,pos);
			if(rmode!=null && neq(mode,rmode))
				mode = utf_mode = null;
		}
		
		if(mode!=null) {
			var ret = new UStr();
			while(pos.i < str.length) {
				var char = char_decode(str,pos,mode);
				if(char<=0) break;
				else ret.push(char);
			}
		
			return ret;
		}else	
			return null;
	}
	
	public static inline function encode(str:UStr,?mode:UTF,?bom:Bool=true):BStr {
		if(mode==null) mode = utf_mode;
		utf_mode = mode;
		
		var ret = new BStr();
		if(bom)
			bom_encode(ret,mode);
		for(char in str) char_encode(ret,char,mode);
		return ret;
	}
	
	public static function bom_encode(str:BStr, ?mode:UTF):Int {
		if(mode==null) mode = utf_mode;
		utf_mode = mode;
		
		var ret = 0;
		switch(mode) {
			case _utf8:
				str.push(0xEF); str.push(0xBB); str.push(0xBF);
				ret = 3;
			case _utf16(be):
				if(be) {
					str.push(0xFF); str.push(0xFE);
				}else {
					str.push(0xFE); str.push(0xFF);
				}
				ret = 2;
			case _utf32(be):
				if(be) {
					str.push(0); str.push(0); str.push(0xFE); str.push(0xFF);
				}else {
					str.push(0xFF); str.push(0xFE); str.push(0); str.push(0);
				}
				ret = 4;
		}
		return ret;
	}
	public static function bom_decode(str:BStr, pos:Integer):UTF {
		if(pos.i+2 >= str.length) return utf_mode = null;
		var c0 = str[pos.i];
		if(c0 == 0xEF) {
			if(str[pos.i+1]==0xBB && pos.i+3 < str.length && str[pos.i+2]==0xBF) {
				pos.i += 3;
				return utf_mode = _utf8;
			}else return utf_mode = null;
		}else if(c0 == 0) {
			if(pos.i+4 < str.length
			&& str[pos.i+1]==0 && str[pos.i+2]==0xFE && str[pos.i+3]==0xFF) {
				pos.i += 4;
				return utf_mode = _utf32(true);
			}else return utf_mode = null;
		}else if(c0 == 0xFE) {
			if(str[pos.i+1] == 0xFF) {
				pos.i += 2;
				return utf_mode = _utf16(true);
			}else return utf_mode = null;
		}else if(c0 == 0xFF) {
			if(str[pos.i+1] != 0xFE) return utf_mode = null;
			if(pos.i+4 < str.length && str[pos.i+2]==0 && str[pos.i+3]==0) {
				pos.i += 4;
				return utf_mode = _utf32(false);
			}else {
				pos.i += 2;
				return utf_mode = _utf16(false);
			}
		}else return utf_mode = null;
	}
	
	public static function char_encode(str:BStr, char:WChar, ?mode:UTF):Int {
		if(mode==null) mode = utf_mode;
		utf_mode = mode;
		
		var ret = 0;
		switch(mode) {
			case _utf8:
				if       (char < 0x80) {
					ret = 1;
					str.push(char & 0x7f);
				} else if  (char < 0x800) {
					ret = 2;
					str.push( 0xc0 | (char >>> 6));
					str.push( 0x80 | (char & 0x3f));
				}else if (char < 0x10000) {
					ret = 3;
					str.push( 0xe0 | (char >>> 12));
					str.push( 0x80 | ((char >>> 6) & 0x3f));
					str.push( 0x80 | (char & 0x3f));
				}else {
					ret = 4;
					str.push( 0xf0 | (char >>> 18));
					str.push( 0x80 | ((char >>> 12) & 0x3f));
					str.push( 0x80 | ((char >>> 6) & 0x3f));
					str.push( 0x80 | (char & 0x3f));
				}
			case _utf16(be):
				$(mixin U16(x) {
					if (be) { str.push(x >>> 8); str.push(x & 0xff); }
					else    { str.push(x & 0xff); str.push(x >>> 8); }
				});
			
				if (char < 0x10000) {
					ret = 2;
					U16(char)
				} else {
					ret = 4;
					var xp = char - 0x10000;
					var xh = (xp >>> 10) + 0xd800;
					var xl = (xp & 0x3ff) + 0xdc00;
					
					U16(xh); U16(xl);
				}
			case _utf32(be):
				ret = 4;
				if(be) {
					str.push(char >>> 24);
					str.push((char >>> 16) & 0xff);
					str.push((char >>> 8 ) & 0xff);
					str.push(char & 0xff);
				}else {
					str.push(char & 0xff);
					str.push((char >>> 8 ) & 0xff);
					str.push((char >>> 16) & 0xff);
					str.push(char >>> 24);
				}
		}
		return ret;
	}
	public static function char_decode(str:BStr, pos:Integer, ?mode:UTF):WChar {
		if(mode==null) mode = utf_mode;
		utf_mode = mode;
		var ERR = -1;
		
		switch(mode) {
			case _utf8: {
				if(pos.i >= str.length) return ERR;
				var c0 = str[pos.i];
			
				$(mixin TEST(N)
					if(pos.i + N >= str.length) return ERR;
					var c`N = str[pos.i+N];
					if((c`N&0xc0) != 0x80) return ERR
				);
				
				if((c0&0x80) == 0) {
					pos.i++;
					return c0;
				}
				else if((c0&0xe0) == 0xc0) {
					TEST(1);
					pos.i += 2;
					return ((c0&0x1f)<<6) | (c1&0x3f);
				}
				else if((c0&0xf0) == 0xe0) {
					TEST(1); TEST(2);
					pos.i += 3;
					return ((c0&0xf)<<12) | ((c1&0x3f)<<6) | (c2&0x3f);
				}
				else if((c0&0xf8) == 0xf0) {
					TEST(1); TEST(2); TEST(3);
					pos.i += 4;
					return ((c0&0x7)<<18) | ((c1&0x3f)<<12) | ((c2&0x3f)<<6) | (c3&0x3f);
				}
				else return -1;
			}
			case _utf16(be): {
				$(mixin TEST(N) 
					if(pos.i+N >= str.length) return ERR;
					var c`N = str[pos.i+N]
				);
				$(mixin U16(u,l) (if(be) (l<<8)|u else (u<<8)|l));
				
				TEST(0); TEST(1);
				var xh = U16(c0,c1);
				
				if(xh >= 0xd800 && xh < 0xdc00) {
					TEST(2); TEST(3);
					var xl = U16(c2,c3);
					if(xl>=0xdc00 && xl<0xe000) {
						pos.i += 4;
						return ((xl-0xdc00) | ((xh-0xd800)<<10)) + 0x10000;
					}else
						return ERR;
				}else {
					pos.i += 2;
					return xh;
				}
			}
			case _utf32(be):
				if(pos.i+4 > str.length) return ERR;
				var c0 = str[pos.i++]; var c1 = str[pos.i++];
				var c2 = str[pos.i++]; var c3 = str[pos.i++];
				return
					if(be) (c0 << 24) | (c1 << 16) | (c2 << 8) | c3
					else   (c3 << 24) | (c2 << 16) | (c1 << 8) | c0;
		}
	}
}