#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "third_party/libteken/teken/teken.h"

#define NUM_ROWS 100

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

#if 0
  fprintf(stderr, "cursor: row=%u, col=%u\n", (unsigned)pos->tp_row,
          (unsigned)pos->tp_col);
#endif

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

#if 0
  fprintf(stderr, "putchar: row=%u, col=%u, ch=%u\n", (unsigned)pos->tp_row,
          (unsigned)pos->tp_col, (unsigned)ch);
#endif

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

#if 0
  fprintf(stderr, "fill: rect=((row=%u, col=%u), (row=%u, col=%u)), ch=%u\n",
          (unsigned)rect->tr_begin.tp_row, (unsigned)rect->tr_begin.tp_col,
          (unsigned)rect->tr_end.tp_row, (unsigned)rect->tr_end.tp_col,
          (unsigned)ch);
#endif

  struct State* st = (struct State*)ctx;
  for (unsigned row = rect->tr_begin.tp_row; row < rect->tr_begin.tp_row;
       row++) {
    for (unsigned col = rect->tr_begin.tp_col; col < rect->tr_begin.tp_col;
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

#if 0
  fprintf(stderr,
          "copy: rect=((row=%u, col=%u), (row=%u, col=%u)), row=%u, col=%u\n",
          (unsigned)rect->tr_begin.tp_row, (unsigned)rect->tr_begin.tp_col,
          (unsigned)rect->tr_end.tp_row, (unsigned)rect->tr_end.tp_col,
          (unsigned)pos->tp_row, (unsigned)pos->tp_col);
#endif

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

int main(int argc, char** argv) {
  const teken_funcs_t callbacks = {BellCallback, CursorCallback,
                                   PutcharCallback, FillCallback, CopyCallback,
                                   ParamCallback, RespondCallback};
  struct State st = {};
  teken_t terminal;
  teken_init(&terminal, &callbacks, &st);

  int c;
  while ((c = getchar()) != EOF) {
    unsigned char ch = (unsigned char)c;
    teken_input(&terminal, &ch, 1);
  }

  // Assume the standard dimensions for now.
  for (unsigned row = 0; row < 24; row++) {
    for (unsigned col = 0; col < 80; col++) {
      // Let's hope no one went all Unicode on me.
      putchar((int)st.ch[row][col]);
    }
    putchar('\n');
  }

  return 0;
}
