package junkfile

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/Shougo/goda-fi-ext/ext/kind/file"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"
)

type host struct {
	dir   string
	calls []string
}

func (h *host) Meta() sdk.Meta { return sdk.Meta{Host: sdk.HostNone} }
func (h *host) Call(_ context.Context, fn string, _ ...any) (any, error) {
	h.calls = append(h.calls, fn)
	return nil, nil
}
func (h *host) Notify(context.Context, string, ...any) error { return nil }
func (h *host) Eval(context.Context, string) (any, error)    { return h.dir, nil }
func (h *host) Cmd(context.Context, string) error            { return nil }

func TestGather(t *testing.T) {
	dir := t.TempDir()
	for _, name := range []string{
		"2026/10/2026-10-30-120000.md",
		"2026/11/2026-11-01-090000.go",
		"2025/12/2025-12-31-235959.txt",
	} {
		p := filepath.Join(dir, filepath.FromSlash(name))
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, nil, 0o644); err != nil {
			t.Fatal(err)
		}
	}
	h := &host{dir: dir}
	s := source{now: func() time.Time { return time.Date(2026, 11, 1, 19, 3, 4, 0, time.Local) }}
	var got []fi.Item
	err := s.Gather(context.Background(), h, fi.GatherArgs{Input: "vim"}, func(items []fi.Item) error {
		got = append(got, items...)
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(h.calls) != 1 || h.calls[0] != "junkfile#init" {
		t.Errorf("calls %q", h.calls)
	}
	var words []string
	for _, it := range got {
		words = append(words, it.Word)
	}
	want := []string{
		"2026-11-01-190304.vim",
		"2026/11/2026-11-01-090000.go",
		"2026/10/2026-10-30-120000.md",
		"2025/12/2025-12-31-235959.txt",
	}
	if len(words) != len(want) {
		t.Fatalf("words %q", words)
	}
	for i := range want {
		if words[i] != want[i] {
			t.Errorf("words %q, want %q", words, want)
			break
		}
	}
	if got[0].Display != "[new] 2026-11-01-190304.vim" {
		t.Errorf("display %q", got[0].Display)
	}
	if p := got[0].Action.(file.ActionData).Path; p != filepath.Join(dir, "2026", "11", "2026-11-01-190304.vim") {
		t.Errorf("new path %q", p)
	}
	if p := got[1].Action.(file.ActionData).Path; p != filepath.Join(dir, "2026", "11", "2026-11-01-090000.go") {
		t.Errorf("path %q", p)
	}
}
