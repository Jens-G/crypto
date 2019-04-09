package haxe.crypto;

import haxe.ds.Vector;
import haxe.io.Bytes;

import haxe.crypto.mode.*;
import haxe.crypto.padding.*;

class Aes
{
	static var SBOX:Vector<Int>;
	static var RSBOX:Vector<Int>;
	static var POWER3:Vector<Int>;
	static var LOG3:Vector<Int>;
	static var RCON:Vector<Int>;

	static var SBOX_ARRAY:Array<Int> =  [
			0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
			0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
			0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
			0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
			0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
			0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
			0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
			0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
			0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
			0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
			0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
			0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
			0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
			0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
			0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
			0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
		];

	static var RSBOX_ARRAY:Array<Int> =  [
			0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
			0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
			0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
			0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
			0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
			0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
			0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
			0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
			0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
			0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
			0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
			0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
			0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
			0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
			0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
			0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
		];
	
	static var POWER3_ARRAY:Array<Int>=[
			0x01, 0x03, 0x05, 0x0f, 0x11, 0x33, 0x55, 0xff, 0x1a, 0x2e, 0x72, 0x96, 0xa1, 0xf8, 0x13, 0x35,
			0x5f, 0xe1, 0x38, 0x48, 0xd8, 0x73, 0x95, 0xa4, 0xf7, 0x02, 0x06, 0x0a, 0x1e, 0x22, 0x66, 0xaa,
			0xe5, 0x34, 0x5c, 0xe4, 0x37, 0x59, 0xeb, 0x26, 0x6a, 0xbe, 0xd9, 0x70, 0x90, 0xab, 0xe6, 0x31,
			0x53, 0xf5, 0x04, 0x0c, 0x14, 0x3c, 0x44, 0xcc, 0x4f, 0xd1, 0x68, 0xb8, 0xd3, 0x6e, 0xb2, 0xcd,
			0x4c, 0xd4, 0x67, 0xa9, 0xe0, 0x3b, 0x4d, 0xd7, 0x62, 0xa6, 0xf1, 0x08, 0x18, 0x28, 0x78, 0x88,
			0x83, 0x9e, 0xb9, 0xd0, 0x6b, 0xbd, 0xdc, 0x7f, 0x81, 0x98, 0xb3, 0xce, 0x49, 0xdb, 0x76, 0x9a,
			0xb5, 0xc4, 0x57, 0xf9, 0x10, 0x30, 0x50, 0xf0, 0x0b, 0x1d, 0x27, 0x69, 0xbb, 0xd6, 0x61, 0xa3,
			0xfe, 0x19, 0x2b, 0x7d, 0x87, 0x92, 0xad, 0xec, 0x2f, 0x71, 0x93, 0xae, 0xe9, 0x20, 0x60, 0xa0,
			0xfb, 0x16, 0x3a, 0x4e, 0xd2, 0x6d, 0xb7, 0xc2, 0x5d, 0xe7, 0x32, 0x56, 0xfa, 0x15, 0x3f, 0x41,
			0xc3, 0x5e, 0xe2, 0x3d, 0x47, 0xc9, 0x40, 0xc0, 0x5b, 0xed, 0x2c, 0x74, 0x9c, 0xbf, 0xda, 0x75,
			0x9f, 0xba, 0xd5, 0x64, 0xac, 0xef, 0x2a, 0x7e, 0x82, 0x9d, 0xbc, 0xdf, 0x7a, 0x8e, 0x89, 0x80,
			0x9b, 0xb6, 0xc1, 0x58, 0xe8, 0x23, 0x65, 0xaf, 0xea, 0x25, 0x6f, 0xb1, 0xc8, 0x43, 0xc5, 0x54,
			0xfc, 0x1f, 0x21, 0x63, 0xa5, 0xf4, 0x07, 0x09, 0x1b, 0x2d, 0x77, 0x99, 0xb0, 0xcb, 0x46, 0xca,
			0x45, 0xcf, 0x4a, 0xde, 0x79, 0x8b, 0x86, 0x91, 0xa8, 0xe3, 0x3e, 0x42, 0xc6, 0x51, 0xf3, 0x0e,
			0x12, 0x36, 0x5a, 0xee, 0x29, 0x7b, 0x8d, 0x8c, 0x8f, 0x8a, 0x85, 0x94, 0xa7, 0xf2, 0x0d, 0x17,
			0x39, 0x4b, 0xdd, 0x7c, 0x84, 0x97, 0xa2, 0xfd, 0x1c, 0x24, 0x6c, 0xb4, 0xc7, 0x52, 0xf6
		];

    static var LOG3_ARRAY:Array<Int> = [
			  0,   0,  25,   1,  50,   2,  26, 198,  75, 199,  27, 104,  51, 238, 223,   3,
			100,   4, 224,  14,  52, 141, 129, 239,  76, 113,   8, 200, 248, 105,  28, 193,
			125, 194,  29, 181, 249, 185,  39, 106,  77, 228, 166, 114, 154, 201,   9, 120,
			101,  47, 138,   5,  33,  15, 225,  36,  18, 240, 130,  69,  53, 147, 218, 142,
			150, 143, 219, 189,  54, 208, 206, 148,  19,  92, 210, 241,  64,  70, 131,  56,
			102, 221, 253,  48, 191,   6, 139,  98, 179,  37, 226, 152,  34, 136, 145,  16,
			126, 110,  72, 195, 163, 182,  30,  66,  58, 107,  40,  84, 250, 133,  61, 186,
 			 43, 121,  10,  21, 155, 159,  94, 202,  78, 212, 172, 229, 243, 115, 167,  87,
			175,  88, 168,  80, 244, 234, 214, 116,  79, 174, 233, 213, 231, 230, 173, 232,
 			 44, 215, 117, 122, 235,  22,  11, 245,  89, 203,  95, 176, 156, 169,  81, 160,
			127,  12, 246, 111,  23, 196,  73, 236, 216,  67,  31,  45, 164, 118, 123, 183,
			204, 187,  62,  90, 251,  96, 177, 134,  59,  82, 161, 108, 170,  85,  41, 157,
			151, 178, 135, 144,  97, 190, 220, 252, 188, 149, 207, 205,  55,  63,  91, 209,
 			 83,  57, 132,  60,  65, 162, 109,  71,  20,  42, 158,  93,  86, 242, 211, 171,
 			 68,  17, 146, 217,  35,  32,  46, 137, 180, 124, 184,  38, 119, 153, 227, 165,
			103,  74, 237, 222, 197,  49, 254,  24,  13,  99, 140, 128, 192, 247, 112,   7
		];

	static var RCON_ARRAY:Array<Int> = [0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36 ]; 

	static inline var NB:Int = 4;
	static inline var BLOCK_SIZE : Int = 16;

	private var roundKey:Vector<Int>;
	private var state:Vector<Vector<Int>>;

	public var Nk(default, null):Int;
	public var Nr(default, null):Int;

	public var iv(default, set):Bytes;
	
	function set_iv(vector) 
	{
		iv = vector;
		if (iv == null) 
		{
			iv = Bytes.alloc(BLOCK_SIZE);
			iv.fill(0,BLOCK_SIZE,0x00);
		}
		return iv;
	}

	public function new(?key:Bytes, ?iv:Bytes)
	{
		SBOX = Vector.fromArrayCopy(SBOX_ARRAY);
		RSBOX = Vector.fromArrayCopy(RSBOX_ARRAY);
		POWER3 = Vector.fromArrayCopy(POWER3_ARRAY);
		LOG3 = Vector.fromArrayCopy(LOG3_ARRAY);
		RCON = Vector.fromArrayCopy(RCON_ARRAY);

		state = new Vector<Vector<Int>>(4);
		if ( key != null ) init(key,iv);
	}

	public function init(key:Bytes, ?iv:Bytes):Void
	{
		var keyLength = key.length;

		Nk = keyLength >> 2;
		Nr = Nk + 6; 

		this.iv = iv;
		roundKey = keyExpansion(key);
	}

	public function getBlockSize():Int
	{
		return BLOCK_SIZE;
	}

	public function encrypt(cipherMode:Mode, data:Bytes, ?padding:Padding=Padding.PKCS7):Bytes
	{
		var out:Bytes;

		switch(padding)  {
			//CBC, ECB  and PCBC requires padding
			case Padding.NoPadding:
				out = NoPadding.pad(data,BLOCK_SIZE); 
			case Padding.PKCS7:
				out = PKCS7.pad(data,BLOCK_SIZE);
			case Padding.BitPadding:
				out = BitPadding.pad(data,BLOCK_SIZE);
			case Padding.AnsiX923:
				out = AnsiX923.pad(data,BLOCK_SIZE);
			case Padding.ISO10126:
				out = ISO10126.pad(data,BLOCK_SIZE);
			case Padding.NullPadding:
				out = NullPadding.pad(data,BLOCK_SIZE);
			case Padding.SpacePadding:
				out = SpacePadding.pad(data,BLOCK_SIZE);
			case Padding.TBC:
				out = TBC.pad(data,BLOCK_SIZE);
		}

		switch (cipherMode) {
			case Mode.CBC:
				CBC.encrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.ECB:
				ECB.encrypt(out,BLOCK_SIZE,encryptBlock);
			case Mode.PCBC:
				PCBC.encrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.CTR:
				CTR.encrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.CFB:
				CFB.encrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.OFB:
				OFB.encrypt(out,iv,BLOCK_SIZE,encryptBlock);
		}

		return out;
	}

	public function decrypt(cipherMode:Mode, data:Bytes, ?padding:Padding=Padding.PKCS7):Bytes 
	{
		var out:Bytes = data;

		switch (cipherMode) {
			case Mode.CBC:
				CBC.decrypt(out,iv,BLOCK_SIZE,decryptBlock);
			case Mode.ECB:
				ECB.decrypt(out,BLOCK_SIZE,decryptBlock);
			case Mode.PCBC:
				PCBC.decrypt(out,iv,BLOCK_SIZE,decryptBlock);
			case Mode.CTR:
				CTR.decrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.CFB:
				CFB.decrypt(out,iv,BLOCK_SIZE,encryptBlock);
			case Mode.OFB:
				OFB.decrypt(out,iv,BLOCK_SIZE,encryptBlock);
		}

		switch(padding)  {
			case Padding.NoPadding:
				out = NoPadding.unpad(out);
			case Padding.PKCS7:
				out = PKCS7.unpad(out);
			case Padding.BitPadding:
				out = BitPadding.unpad(out);
			case Padding.AnsiX923:
				out = AnsiX923.unpad(out);
			case Padding.ISO10126:
				out = ISO10126.unpad(out);
			case Padding.NullPadding:
				out = NullPadding.unpad(out);
			case Padding.SpacePadding:
				out = SpacePadding.unpad(out);
			case Padding.TBC:
				out = TBC.unpad(out);
		}

		return out;
	}

	private function encryptBlock( src:Bytes, srcIndex:Int, dst:Bytes, dstIndex:Int):Void
	{
		for(i in 0...4) {
			state[i] = Vector.fromArrayCopy([ src.get(4*i+srcIndex) , src.get(4*i+srcIndex+1) , src.get(4*i+srcIndex+2) , src.get(4*i+srcIndex+3) ]);
		}

		addRoundKey(0); 

		for (round  in 1...Nr)
		{
			subBytes();
			shiftRows();
			mixColumns();
			addRoundKey(round);
		}

		subBytes();
		shiftRows();
		addRoundKey(Nr);

		for(i in 0...4) {
			for(j in 0...4) {
				dst.set(4*i+j+dstIndex,state[i][j]);
			}
		}
	}

	private function decryptBlock( src:Bytes, srcIndex:Int, dst:Bytes, dstIndex:Int):Void
	{
		for(i in 0...4) {
			state[i] = Vector.fromArrayCopy([ src.get(4*i+srcIndex) , src.get(4*i+srcIndex+1) , src.get(4*i+srcIndex+2) , src.get(4*i+srcIndex+3) ]);
		}

		addRoundKey(Nr);

		var round : Int = Nr -1;
		while ( round > 0)
		{
			invShiftRows();
			invSubBytes();
			addRoundKey(round);
			invMixColumns();
			round--;
		}

		invShiftRows();
		invSubBytes();
		addRoundKey(0);

		for(i in 0...4) {
			for(j in 0...4) {
				dst.set(4*i+j+dstIndex,state[i][j]);
			}
		}
	}
			 
	private function rotWord(w:Vector<Int>):Vector<Int>
	{
		var tmp:Int = w[0];
		for(i in 0...3)  w[i] = w[i+1];
		w[3] = tmp;
		return w;
	}
	
	private function subWord(w:Vector<Int>):Vector<Int>
	{
		for(i in 0...4) w[i] = SBOX[w[i]];
		return w;
	}

	private function keyExpansion(key:Bytes) : Vector<Int>
	{

		var roundKey:Vector<Int> = new Vector<Int>(4*NB*(Nr+1));
		var temp:Vector<Int> = new Vector<Int>(NB);
		
		for (i in 0...Nk) {
			for (j in 0...4) {
				roundKey[4*i+j] = key.get(4*i+j);
			}
		}

		for (i in Nk...(NB*(Nr+1))) {
			for ( j in 0...NB) temp[j] = roundKey[4*(i-1)+j];
			if (i % Nk == 0) {
				temp = subWord(rotWord(temp));
				var k = Std.int(i/Nk);
				temp[0]  ^= RCON[k];
			} else if (Nk > 6 && (i % Nk == 4) ) {
				temp = subWord(temp);
			}
			var k = i * 4;
			var m = (i - Nk) * 4;
			for (j in 0...NB) roundKey[k + j] = roundKey[m + j] ^ temp[j];
		}
		return roundKey;
	}

	private function addRoundKey(round:Int):Void
	{
		round <<= 2;
		for (i in 0...4)
		{
			for(j in 0...NB) state[i][j] ^= roundKey[ round*4 + i*NB +j ];
		}
	}

	private function subBytes():Void
	{
		for (i in 0...4)
		{
			for (j in 0...4) {
				state[i][j] = SBOX[state[i][j]];
			}
		}
	}

	private  function shiftRows():Void
	{
		var t:Vector<Int> = new Vector<Int>(4);
		for (i in 1...4) {
			for (j in 0...4)
				t[j] = state[(j+i)%4][i];
			for (j in 0...4)
				state[j][i] = t[j];
			}
	}

	private function mixColumns():Void
	{
		var t:Vector<Int> = new Vector<Int>(4);
		for (i in 0...4) {
			for (j in 0...4) {
				t[j] = state[i][j];
			}
			for (j in 0...4) {
				state[i][j] = mul(0x02, t[j])
					^ mul(0x03, t[(j+1)%4])
					^ mul(0x01, t[(j+2)%4])
					^ mul(0x01, t[(j+3)%4]);
			}
		}
	}

	private function mul(a:Int, b:Int):Int
	{
		return (a != 0 && b != 0)?POWER3[(LOG3[a]+LOG3[b])%255]:0;
	}
	
	private function invMixColumns():Void
	{
		var t:Vector<Int> = new Vector<Int>(4);
		for (i in 0...4) {
			for (j in 0...4)
				t[j] = state[i][j];
			for (j in 0...4) {
				state[i][j] = mul(0x0e, t[j])
					^ mul(0x0b, t[(j+1)%4])
					^ mul(0x0d, t[(j+2)%4])
					^ mul(0x09, t[(j+3)%4]);
			}
		}
	}

	private function invSubBytes():Void
	{
		for(i in 0...4)
			for(j in 0...4) 
				state[j][i] = RSBOX[state[j][i]];
	}

	private function invShiftRows():Void
	{
		var t:Vector<Int> = new Vector<Int>(4);
		for (i in 1...4) {
			for (j in 0...4)
				t[j] = state[(j-i+4)%4][i];
			for (j in 0...4)
				state[j][i] = t[j];
		}
	}
}