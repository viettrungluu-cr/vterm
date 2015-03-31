#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "third_party/libteken/teken/teken.h"

#define NUM_ROWS 100

int g_verbosity = 0;

// Should be zero-initialized.
struct State {
  teken_char_t ch[NUM_ROWS][T_NUMCOL];
  teken_attr_t attr[NUM_ROWS][T_NUMCOL];
  teken_pos_t cursor_pos;
};

void BellCallback(void* ctx) {
  // TODO(vtl)
  fprintf(stderr, "bell\n");
}

void CursorCallback(void* ctx, const teken_pos_t* pos) {
  assert(ctx);
  assert(pos);
  assert(pos->tp_row < NUM_ROWS);
  assert(pos->tp_col < T_NUMCOL);

  if (g_verbosity >= 1) {
    fprintf(stderr, "cursor: row=%u, col=%u\n", (unsigned)pos->tp_row,
            (unsigned)pos->tp_col);
  }

  struct State* st = (struct State*)ctx;
  st->cursor_pos = *pos;
}

void PutcharCallback(void* ctx,
                const teken_pos_t* pos,
                teken_char_t ch,
                const teken_attr_t* attr) {
  assert(ctx);
  assert(pos);
  assert(pos->tp_row < NUM_ROWS);
  assert(pos->tp_col < T_NUMCOL);
  assert(attr);

  if (g_verbosity >= 1) {
    fprintf(stderr, "putchar: row=%u, col=%u, ch=%u\n", (unsigned)pos->tp_row,
            (unsigned)pos->tp_col, (unsigned)ch);
  }

  struct State* st = (struct State*)ctx;
  st->ch[pos->tp_row][pos->tp_col] = ch;
  st->attr[pos->tp_row][pos->tp_col] = *attr;
}

void FillCallback(void* ctx,
             const teken_rect_t* rect,
             teken_char_t ch,
             const teken_attr_t* attr) {
  assert(ctx);
  assert(rect);
  assert(rect->tr_begin.tp_row < rect->tr_end.tp_row);
  assert(rect->tr_begin.tp_col < rect->tr_end.tp_col);
  assert(rect->tr_end.tp_row <= NUM_ROWS);  // "end" is non-inclusive.
  assert(rect->tr_end.tp_col <= T_NUMCOL);
  assert(attr);

  if (g_verbosity >= 1) {
    fprintf(stderr, "fill: rect=((row=%u, col=%u), (row=%u, col=%u)), ch=%u\n",
            (unsigned)rect->tr_begin.tp_row, (unsigned)rect->tr_begin.tp_col,
            (unsigned)rect->tr_end.tp_row, (unsigned)rect->tr_end.tp_col,
            (unsigned)ch);
  }

  struct State* st = (struct State*)ctx;
  for (unsigned row = rect->tr_begin.tp_row; row < rect->tr_end.tp_row;
       row++) {
    for (unsigned col = rect->tr_begin.tp_col; col < rect->tr_end.tp_col;
         col++) {
      st->ch[row][col] = ch;
      st->attr[row][col] = *attr;
    }
  }
}

void CopyCallback(void* ctx, const teken_rect_t* rect, const teken_pos_t* pos) {
  assert(ctx);
  assert(rect);
  assert(rect->tr_begin.tp_row < rect->tr_end.tp_row);
  assert(rect->tr_begin.tp_col < rect->tr_end.tp_col);
  assert(rect->tr_end.tp_row <= NUM_ROWS);  // "end" is non-inclusive.
  assert(rect->tr_end.tp_col <= T_NUMCOL);
  unsigned height = rect->tr_end.tp_row - rect->tr_begin.tp_row;
  unsigned width = rect->tr_end.tp_col - rect->tr_begin.tp_col;
  assert(pos);
  assert(pos->tp_row + height <= NUM_ROWS);  // If height is 0, we don't care.
  assert(pos->tp_col + width <= T_NUMCOL);   // If width is 0, we don't care.

  if (g_verbosity >= 1) {
    fprintf(stderr,
            "copy: rect=((row=%u, col=%u), (row=%u, col=%u)), row=%u, col=%u\n",
            (unsigned)rect->tr_begin.tp_row, (unsigned)rect->tr_begin.tp_col,
            (unsigned)rect->tr_end.tp_row, (unsigned)rect->tr_end.tp_col,
            (unsigned)pos->tp_row, (unsigned)pos->tp_col);
  }

  // Memory and copies are cheap, for our purposes, so just bounce (rather than
  // vary directionality).
  teken_char_t ch_bounce[NUM_ROWS][T_NUMCOL];
  teken_attr_t attr_bounce[NUM_ROWS][T_NUMCOL];
  struct State* st = (struct State*)ctx;
  for (unsigned row = 0; row < height; row++) {
    for (unsigned col = 0; col < width; col++) {
      ch_bounce[row][col] =
          st->ch[rect->tr_begin.tp_row + row][rect->tr_begin.tp_col + col];
      attr_bounce[row][col] =
          st->attr[rect->tr_begin.tp_row + row][rect->tr_begin.tp_col + col];
    }
  }
  for (unsigned row = 0; row < height; row++) {
    for (unsigned col = 0; col < width; col++) {
      st->ch[pos->tp_row + row][pos->tp_col + col] = ch_bounce[row][col];
      st->attr[pos->tp_row + row][pos->tp_col + col] = attr_bounce[row][col];
    }
  }
}

void ParamCallback(void* ctx, int cmd, unsigned int val) {
  // TODO(vtl)
  fprintf(stderr, "TODO: param\n");
}

void RespondCallback(void* ctx, const void* buf, size_t size) {
  // TODO(vtl)
  fprintf(stderr, "TODO: respond\n");
}

void PrintUsage(const char* argv0) {
  printf("usage: %s [option]... [--] (FILE|-)...\n\n"
         "(- indicates standard input)\n", argv0);
}

// Note: Emits ' ' for '\0'.
void EscapedPutChar(teken_char_t c) {
  if (c == 0) {
    putchar(' ');
  } else if (c < 32 || c >= 128) {
    printf("\\u%04x", (unsigned)c);
  } else if (c == '"' || c == '\\') {
    printf("\\%c", (int)c);
  } else {
    putchar((int)c);
  }
}

void PrintState(const struct State* st, teken_t* terminal) {
  printf("{\n");

  const teken_pos_t* size = teken_get_winsize(terminal);
  const unsigned height = size->tp_row;
  const unsigned width = size->tp_col;
  assert(height <= NUM_ROWS);
  assert(width <= T_NUMCOL);
  printf("  \"size\": [%u, %u],\n", height, width);

  printf("  \"characters\": [\n");
  for (unsigned row = 0; row < height; row++) {
    printf("    \"");
    for (unsigned col = 0; col < width; col++) {
      // Let's hope no one went all Unicode on me.
      EscapedPutChar(st->ch[row][col]);
    }
    printf((row + 1 == height) ? "\"\n" : "\",\n");
  }
  printf("  ],\n");

  const teken_pos_t* position = teken_get_cursor(terminal);
  const unsigned row = position->tp_row;
  const unsigned col = position->tp_col;
  assert(row <= NUM_ROWS);
  assert(col <= T_NUMCOL);
  printf("  \"position\": [%u, %u]\n", row, col);

  printf("}\n");
}

int main(int argc, char** argv) {
  if (argc < 2) {
    PrintUsage(argv[0]);
    return 0;
  }

  // Consume options first.
  int first_file = 1;
  for (; first_file < argc; first_file++) {
    if (argv[first_file][0] != '-' || strcmp(argv[first_file], "-") == 0)
      break;
    if (strcmp(argv[first_file], "--") == 0) {
      first_file++;
      break;
    }
    if (strcmp(argv[first_file], "-h") == 0 ||
        strcmp(argv[first_file], "--help") == 0) {
      PrintUsage(argv[0]);
      return 0;
    }
    if (strcmp(argv[first_file], "-v") == 0 ||
        strcmp(argv[first_file], "--verbose") == 0) {
      g_verbosity++;
    } else {
      // No other options yet.
      fprintf(stderr, "%s: unknown option %s\n", argv[0], argv[first_file]);
      return 1;
    }
  }

  if (first_file >= argc) {
    fprintf(stderr, "%s: no inputs specified\n", argv[0]);
    return 1;
  }

  const teken_funcs_t callbacks = {BellCallback, CursorCallback,
                                   PutcharCallback, FillCallback, CopyCallback,
                                   ParamCallback, RespondCallback};
  struct State st = {};
  teken_t terminal;
  teken_init(&terminal, &callbacks, &st);

  for (int i = first_file; i < argc; i++) {
    FILE* fp = stdin;
    bool own_fp = false;
    if (strcmp(argv[i], "-") != 0) {
      if (!(fp = fopen(argv[i], "r"))) {
        fprintf(stderr, "%s: error opening %s: %s\n", argv[0], argv[i],
                strerror(errno));
        return 1;
      }
    }

    int c;
    while ((c = getc(fp)) != EOF) {
      unsigned char ch = (unsigned char)c;
      teken_input(&terminal, &ch, 1);
    }

    if (own_fp)
      fclose(fp);
  }

  PrintState(&st, &terminal);

  return 0;
}
