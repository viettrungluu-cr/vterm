int mapIndexToColor(int index) {
  assert(0 <= index && index <= 15);
  switch (index) {
    // xterm colors:
    case 0:
      return mapRGBToColor(0x00, 0x00, 0x00);
    case 1:
      return mapRGBToColor(0x80, 0x00, 0x00);
    case 2:
      return mapRGBToColor(0x00, 0x80, 0x00);
    case 3:
      return mapRGBToColor(0x80, 0x80, 0x00);
    case 4:
      return mapRGBToColor(0x00, 0x00, 0x80);
    case 5:
      return mapRGBToColor(0x80, 0x00, 0x80);
    case 6:
      return mapRGBToColor(0x00, 0x80, 0x80);
    case 7:
      return mapRGBToColor(0xc0, 0xc0, 0xc0);
    case 8:
      return mapRGBToColor(0x80, 0x80, 0x80);
    case 9:
      return mapRGBToColor(0xff, 0x00, 0x00);
    case 10:
      return mapRGBToColor(0x00, 0xff, 0x00);
    case 11:
      return mapRGBToColor(0xff, 0xff, 0x00);
    case 12:
      return mapRGBToColor(0x00, 0x00, 0xff);
    case 13:
      return mapRGBToColor(0xff, 0x00, 0xff);
    case 14:
      return mapRGBToColor(0x00, 0xff, 0xff);
    case 15:
      return mapRGBToColor(0xff, 0xff, 0xff);

    // xterm256-color colors (6x6x6 color cube):
    case 16:
      return mapRGBToColor(0x00, 0x00, 0x00);
    case 17:
      return mapRGBToColor(0x00, 0x00, 0x5f);
    case 18:
      return mapRGBToColor(0x00, 0x00, 0x87);
    case 19:
      return mapRGBToColor(0x00, 0x00, 0xaf);
    case 20:
      return mapRGBToColor(0x00, 0x00, 0xd7);
    case 21:
      return mapRGBToColor(0x00, 0x00, 0xff);
    case 22:
      return mapRGBToColor(0x00, 0x5f, 0x00);
    case 23:
      return mapRGBToColor(0x00, 0x5f, 0x5f);
    case 24:
      return mapRGBToColor(0x00, 0x5f, 0x87);
    case 25:
      return mapRGBToColor(0x00, 0x5f, 0xaf);
    case 26:
      return mapRGBToColor(0x00, 0x5f, 0xd7);
    case 27:
      return mapRGBToColor(0x00, 0x5f, 0xff);
    case 28:
      return mapRGBToColor(0x00, 0x87, 0x00);
    case 29:
      return mapRGBToColor(0x00, 0x87, 0x5f);
    case 30:
      return mapRGBToColor(0x00, 0x87, 0x87);
    case 31:
      return mapRGBToColor(0x00, 0x87, 0xaf);
    case 32:
      return mapRGBToColor(0x00, 0x87, 0xd7);
    case 33:
      return mapRGBToColor(0x00, 0x87, 0xff);
    case 34:
      return mapRGBToColor(0x00, 0xaf, 0x00);
    case 35:
      return mapRGBToColor(0x00, 0xaf, 0x5f);
    case 36:
      return mapRGBToColor(0x00, 0xaf, 0x87);
    case 37:
      return mapRGBToColor(0x00, 0xaf, 0xaf);
    case 38:
      return mapRGBToColor(0x00, 0xaf, 0xd7);
    case 39:
      return mapRGBToColor(0x00, 0xaf, 0xff);
    case 40:
      return mapRGBToColor(0x00, 0xd7, 0x00);
    case 41:
      return mapRGBToColor(0x00, 0xd7, 0x5f);
    case 42:
      return mapRGBToColor(0x00, 0xd7, 0x87);
    case 43:
      return mapRGBToColor(0x00, 0xd7, 0xaf);
    case 44:
      return mapRGBToColor(0x00, 0xd7, 0xd7);
    case 45:
      return mapRGBToColor(0x00, 0xd7, 0xff);
    case 46:
      return mapRGBToColor(0x00, 0xff, 0x00);
    case 47:
      return mapRGBToColor(0x00, 0xff, 0x5f);
    case 48:
      return mapRGBToColor(0x00, 0xff, 0x87);
    case 49:
      return mapRGBToColor(0x00, 0xff, 0xaf);
    case 50:
      return mapRGBToColor(0x00, 0xff, 0xd7);
    case 51:
      return mapRGBToColor(0x00, 0xff, 0xff);
    case 52:
      return mapRGBToColor(0x5f, 0x00, 0x00);
    case 53:
      return mapRGBToColor(0x5f, 0x00, 0x5f);
    case 54:
      return mapRGBToColor(0x5f, 0x00, 0x87);
    case 55:
      return mapRGBToColor(0x5f, 0x00, 0xaf);
    case 56:
      return mapRGBToColor(0x5f, 0x00, 0xd7);
    case 57:
      return mapRGBToColor(0x5f, 0x00, 0xff);
    case 58:
      return mapRGBToColor(0x5f, 0x5f, 0x00);
    case 59:
      return mapRGBToColor(0x5f, 0x5f, 0x5f);
    case 60:
      return mapRGBToColor(0x5f, 0x5f, 0x87);
    case 61:
      return mapRGBToColor(0x5f, 0x5f, 0xaf);
    case 62:
      return mapRGBToColor(0x5f, 0x5f, 0xd7);
    case 63:
      return mapRGBToColor(0x5f, 0x5f, 0xff);
    case 64:
      return mapRGBToColor(0x5f, 0x87, 0x00);
    case 65:
      return mapRGBToColor(0x5f, 0x87, 0x5f);
    case 66:
      return mapRGBToColor(0x5f, 0x87, 0x87);
    case 67:
      return mapRGBToColor(0x5f, 0x87, 0xaf);
    case 68:
      return mapRGBToColor(0x5f, 0x87, 0xd7);
    case 69:
      return mapRGBToColor(0x5f, 0x87, 0xff);
    case 70:
      return mapRGBToColor(0x5f, 0xaf, 0x00);
    case 71:
      return mapRGBToColor(0x5f, 0xaf, 0x5f);
    case 72:
      return mapRGBToColor(0x5f, 0xaf, 0x87);
    case 73:
      return mapRGBToColor(0x5f, 0xaf, 0xaf);
    case 74:
      return mapRGBToColor(0x5f, 0xaf, 0xd7);
    case 75:
      return mapRGBToColor(0x5f, 0xaf, 0xff);
    case 76:
      return mapRGBToColor(0x5f, 0xd7, 0x00);
    case 77:
      return mapRGBToColor(0x5f, 0xd7, 0x5f);
    case 78:
      return mapRGBToColor(0x5f, 0xd7, 0x87);
    case 79:
      return mapRGBToColor(0x5f, 0xd7, 0xaf);
    case 80:
      return mapRGBToColor(0x5f, 0xd7, 0xd7);
    case 81:
      return mapRGBToColor(0x5f, 0xd7, 0xff);
    case 82:
      return mapRGBToColor(0x5f, 0xff, 0x00);
    case 83:
      return mapRGBToColor(0x5f, 0xff, 0x5f);
    case 84:
      return mapRGBToColor(0x5f, 0xff, 0x87);
    case 85:
      return mapRGBToColor(0x5f, 0xff, 0xaf);
    case 86:
      return mapRGBToColor(0x5f, 0xff, 0xd7);
    case 87:
      return mapRGBToColor(0x5f, 0xff, 0xff);
    case 88:
      return mapRGBToColor(0x87, 0x00, 0x00);
    case 89:
      return mapRGBToColor(0x87, 0x00, 0x5f);
    case 90:
      return mapRGBToColor(0x87, 0x00, 0x87);
    case 91:
      return mapRGBToColor(0x87, 0x00, 0xaf);
    case 92:
      return mapRGBToColor(0x87, 0x00, 0xd7);
    case 93:
      return mapRGBToColor(0x87, 0x00, 0xff);
    case 94:
      return mapRGBToColor(0x87, 0x5f, 0x00);
    case 95:
      return mapRGBToColor(0x87, 0x5f, 0x5f);
    case 96:
      return mapRGBToColor(0x87, 0x5f, 0x87);
    case 97:
      return mapRGBToColor(0x87, 0x5f, 0xaf);
    case 98:
      return mapRGBToColor(0x87, 0x5f, 0xd7);
    case 99:
      return mapRGBToColor(0x87, 0x5f, 0xff);
    case 100:
      return mapRGBToColor(0x87, 0x87, 0x00);
    case 101:
      return mapRGBToColor(0x87, 0x87, 0x5f);
    case 102:
      return mapRGBToColor(0x87, 0x87, 0x87);
    case 103:
      return mapRGBToColor(0x87, 0x87, 0xaf);
    case 104:
      return mapRGBToColor(0x87, 0x87, 0xd7);
    case 105:
      return mapRGBToColor(0x87, 0x87, 0xff);
    case 106:
      return mapRGBToColor(0x87, 0xaf, 0x00);
    case 107:
      return mapRGBToColor(0x87, 0xaf, 0x5f);
    case 108:
      return mapRGBToColor(0x87, 0xaf, 0x87);
    case 109:
      return mapRGBToColor(0x87, 0xaf, 0xaf);
    case 110:
      return mapRGBToColor(0x87, 0xaf, 0xd7);
    case 111:
      return mapRGBToColor(0x87, 0xaf, 0xff);
    case 112:
      return mapRGBToColor(0x87, 0xd7, 0x00);
    case 113:
      return mapRGBToColor(0x87, 0xd7, 0x5f);
    case 114:
      return mapRGBToColor(0x87, 0xd7, 0x87);
    case 115:
      return mapRGBToColor(0x87, 0xd7, 0xaf);
    case 116:
      return mapRGBToColor(0x87, 0xd7, 0xd7);
    case 117:
      return mapRGBToColor(0x87, 0xd7, 0xff);
    case 118:
      return mapRGBToColor(0x87, 0xff, 0x00);
    case 119:
      return mapRGBToColor(0x87, 0xff, 0x5f);
    case 120:
      return mapRGBToColor(0x87, 0xff, 0x87);
    case 121:
      return mapRGBToColor(0x87, 0xff, 0xaf);
    case 122:
      return mapRGBToColor(0x87, 0xff, 0xd7);
    case 123:
      return mapRGBToColor(0x87, 0xff, 0xff);
    case 124:
      return mapRGBToColor(0xaf, 0x00, 0x00);
    case 125:
      return mapRGBToColor(0xaf, 0x00, 0x5f);
    case 126:
      return mapRGBToColor(0xaf, 0x00, 0x87);
    case 127:
      return mapRGBToColor(0xaf, 0x00, 0xaf);
    case 128:
      return mapRGBToColor(0xaf, 0x00, 0xd7);
    case 129:
      return mapRGBToColor(0xaf, 0x00, 0xff);
    case 130:
      return mapRGBToColor(0xaf, 0x5f, 0x00);
    case 131:
      return mapRGBToColor(0xaf, 0x5f, 0x5f);
    case 132:
      return mapRGBToColor(0xaf, 0x5f, 0x87);
    case 133:
      return mapRGBToColor(0xaf, 0x5f, 0xaf);
    case 134:
      return mapRGBToColor(0xaf, 0x5f, 0xd7);
    case 135:
      return mapRGBToColor(0xaf, 0x5f, 0xff);
    case 136:
      return mapRGBToColor(0xaf, 0x87, 0x00);
    case 137:
      return mapRGBToColor(0xaf, 0x87, 0x5f);
    case 138:
      return mapRGBToColor(0xaf, 0x87, 0x87);
    case 139:
      return mapRGBToColor(0xaf, 0x87, 0xaf);
    case 140:
      return mapRGBToColor(0xaf, 0x87, 0xd7);
    case 141:
      return mapRGBToColor(0xaf, 0x87, 0xff);
    case 142:
      return mapRGBToColor(0xaf, 0xaf, 0x00);
    case 143:
      return mapRGBToColor(0xaf, 0xaf, 0x5f);
    case 144:
      return mapRGBToColor(0xaf, 0xaf, 0x87);
    case 145:
      return mapRGBToColor(0xaf, 0xaf, 0xaf);
    case 146:
      return mapRGBToColor(0xaf, 0xaf, 0xd7);
    case 147:
      return mapRGBToColor(0xaf, 0xaf, 0xff);
    case 148:
      return mapRGBToColor(0xaf, 0xd7, 0x00);
    case 149:
      return mapRGBToColor(0xaf, 0xd7, 0x5f);
    case 150:
      return mapRGBToColor(0xaf, 0xd7, 0x87);
    case 151:
      return mapRGBToColor(0xaf, 0xd7, 0xaf);
    case 152:
      return mapRGBToColor(0xaf, 0xd7, 0xd7);
    case 153:
      return mapRGBToColor(0xaf, 0xd7, 0xff);
    case 154:
      return mapRGBToColor(0xaf, 0xff, 0x00);
    case 155:
      return mapRGBToColor(0xaf, 0xff, 0x5f);
    case 156:
      return mapRGBToColor(0xaf, 0xff, 0x87);
    case 157:
      return mapRGBToColor(0xaf, 0xff, 0xaf);
    case 158:
      return mapRGBToColor(0xaf, 0xff, 0xd7);
    case 159:
      return mapRGBToColor(0xaf, 0xff, 0xff);
    case 160:
      return mapRGBToColor(0xd7, 0x00, 0x00);
    case 161:
      return mapRGBToColor(0xd7, 0x00, 0x5f);
    case 162:
      return mapRGBToColor(0xd7, 0x00, 0x87);
    case 163:
      return mapRGBToColor(0xd7, 0x00, 0xaf);
    case 164:
      return mapRGBToColor(0xd7, 0x00, 0xd7);
    case 165:
      return mapRGBToColor(0xd7, 0x00, 0xff);
    case 166:
      return mapRGBToColor(0xd7, 0x5f, 0x00);
    case 167:
      return mapRGBToColor(0xd7, 0x5f, 0x5f);
    case 168:
      return mapRGBToColor(0xd7, 0x5f, 0x87);
    case 169:
      return mapRGBToColor(0xd7, 0x5f, 0xaf);
    case 170:
      return mapRGBToColor(0xd7, 0x5f, 0xd7);
    case 171:
      return mapRGBToColor(0xd7, 0x5f, 0xff);
    case 172:
      return mapRGBToColor(0xd7, 0x87, 0x00);
    case 173:
      return mapRGBToColor(0xd7, 0x87, 0x5f);
    case 174:
      return mapRGBToColor(0xd7, 0x87, 0x87);
    case 175:
      return mapRGBToColor(0xd7, 0x87, 0xaf);
    case 176:
      return mapRGBToColor(0xd7, 0x87, 0xd7);
    case 177:
      return mapRGBToColor(0xd7, 0x87, 0xff);
    case 178:
      return mapRGBToColor(0xd7, 0xaf, 0x00);
    case 179:
      return mapRGBToColor(0xd7, 0xaf, 0x5f);
    case 180:
      return mapRGBToColor(0xd7, 0xaf, 0x87);
    case 181:
      return mapRGBToColor(0xd7, 0xaf, 0xaf);
    case 182:
      return mapRGBToColor(0xd7, 0xaf, 0xd7);
    case 183:
      return mapRGBToColor(0xd7, 0xaf, 0xff);
    case 184:
      return mapRGBToColor(0xd7, 0xd7, 0x00);
    case 185:
      return mapRGBToColor(0xd7, 0xd7, 0x5f);
    case 186:
      return mapRGBToColor(0xd7, 0xd7, 0x87);
    case 187:
      return mapRGBToColor(0xd7, 0xd7, 0xaf);
    case 188:
      return mapRGBToColor(0xd7, 0xd7, 0xd7);
    case 189:
      return mapRGBToColor(0xd7, 0xd7, 0xff);
    case 190:
      return mapRGBToColor(0xd7, 0xff, 0x00);
    case 191:
      return mapRGBToColor(0xd7, 0xff, 0x5f);
    case 192:
      return mapRGBToColor(0xd7, 0xff, 0x87);
    case 193:
      return mapRGBToColor(0xd7, 0xff, 0xaf);
    case 194:
      return mapRGBToColor(0xd7, 0xff, 0xd7);
    case 195:
      return mapRGBToColor(0xd7, 0xff, 0xff);
    case 196:
      return mapRGBToColor(0xff, 0x00, 0x00);
    case 197:
      return mapRGBToColor(0xff, 0x00, 0x5f);
    case 198:
      return mapRGBToColor(0xff, 0x00, 0x87);
    case 199:
      return mapRGBToColor(0xff, 0x00, 0xaf);
    case 200:
      return mapRGBToColor(0xff, 0x00, 0xd7);
    case 201:
      return mapRGBToColor(0xff, 0x00, 0xff);
    case 202:
      return mapRGBToColor(0xff, 0x5f, 0x00);
    case 203:
      return mapRGBToColor(0xff, 0x5f, 0x5f);
    case 204:
      return mapRGBToColor(0xff, 0x5f, 0x87);
    case 205:
      return mapRGBToColor(0xff, 0x5f, 0xaf);
    case 206:
      return mapRGBToColor(0xff, 0x5f, 0xd7);
    case 207:
      return mapRGBToColor(0xff, 0x5f, 0xff);
    case 208:
      return mapRGBToColor(0xff, 0x87, 0x00);
    case 209:
      return mapRGBToColor(0xff, 0x87, 0x5f);
    case 210:
      return mapRGBToColor(0xff, 0x87, 0x87);
    case 211:
      return mapRGBToColor(0xff, 0x87, 0xaf);
    case 212:
      return mapRGBToColor(0xff, 0x87, 0xd7);
    case 213:
      return mapRGBToColor(0xff, 0x87, 0xff);
    case 214:
      return mapRGBToColor(0xff, 0xaf, 0x00);
    case 215:
      return mapRGBToColor(0xff, 0xaf, 0x5f);
    case 216:
      return mapRGBToColor(0xff, 0xaf, 0x87);
    case 217:
      return mapRGBToColor(0xff, 0xaf, 0xaf);
    case 218:
      return mapRGBToColor(0xff, 0xaf, 0xd7);
    case 219:
      return mapRGBToColor(0xff, 0xaf, 0xff);
    case 220:
      return mapRGBToColor(0xff, 0xd7, 0x00);
    case 221:
      return mapRGBToColor(0xff, 0xd7, 0x5f);
    case 222:
      return mapRGBToColor(0xff, 0xd7, 0x87);
    case 223:
      return mapRGBToColor(0xff, 0xd7, 0xaf);
    case 224:
      return mapRGBToColor(0xff, 0xd7, 0xd7);
    case 225:
      return mapRGBToColor(0xff, 0xd7, 0xff);
    case 226:
      return mapRGBToColor(0xff, 0xff, 0x00);
    case 227:
      return mapRGBToColor(0xff, 0xff, 0x5f);
    case 228:
      return mapRGBToColor(0xff, 0xff, 0x87);
    case 229:
      return mapRGBToColor(0xff, 0xff, 0xaf);
    case 230:
      return mapRGBToColor(0xff, 0xff, 0xd7);
    case 231:
      return mapRGBToColor(0xff, 0xff, 0xff);

    // xterm256-color colors (grayscale ramp):
    case 232:
      return mapRGBToColor(0x08, 0x08, 0x08);
    case 233:
      return mapRGBToColor(0x12, 0x12, 0x12);
    case 234:
      return mapRGBToColor(0x1c, 0x1c, 0x1c);
    case 235:
      return mapRGBToColor(0x26, 0x26, 0x26);
    case 236:
      return mapRGBToColor(0x30, 0x30, 0x30);
    case 237:
      return mapRGBToColor(0x3a, 0x3a, 0x3a);
    case 238:
      return mapRGBToColor(0x44, 0x44, 0x44);
    case 239:
      return mapRGBToColor(0x4e, 0x4e, 0x4e);
    case 240:
      return mapRGBToColor(0x58, 0x58, 0x58);
    case 241:
      return mapRGBToColor(0x60, 0x60, 0x60);
    case 242:
      return mapRGBToColor(0x66, 0x66, 0x66);
    case 243:
      return mapRGBToColor(0x76, 0x76, 0x76);
    case 244:
      return mapRGBToColor(0x80, 0x80, 0x80);
    case 245:
      return mapRGBToColor(0x8a, 0x8a, 0x8a);
    case 246:
      return mapRGBToColor(0x94, 0x94, 0x94);
    case 247:
      return mapRGBToColor(0x9e, 0x9e, 0x9e);
    case 248:
      return mapRGBToColor(0xa8, 0xa8, 0xa8);
    case 249:
      return mapRGBToColor(0xb2, 0xb2, 0xb2);
    case 250:
      return mapRGBToColor(0xbc, 0xbc, 0xbc);
    case 251:
      return mapRGBToColor(0xc6, 0xc6, 0xc6);
    case 252:
      return mapRGBToColor(0xd0, 0xd0, 0xd0);
    case 253:
      return mapRGBToColor(0xda, 0xda, 0xda);
    case 254:
      return mapRGBToColor(0xe4, 0xe4, 0xe4);
    case 255:
      return mapRGBToColor(0xee, 0xee, 0xee);
  }
}

int mapRGBToColor(int red, int green, int blue) {
  assert(0 <= red && red <= 255);
  assert(0 <= green && green <= 255);
  assert(0 <= blue && blue <= 255);

  return (red << 16) | (green << 8) | blue;
}
