// Package junkfile is the source "junkfile" of goda-fi.vim
// (https://github.com/Shougo/goda-fi.vim), as the ddu source of
// junkfile.vim: the junk files below g:junkfile#directory, the latest
// first, after an item of a new one named by the input.
//
// Add it in your configuration of goda-fi.vim:
//
//	import "github.com/Shougo/junkfile.vim/ext/source/junkfile"
//
//	b.AddSource(junkfile.New())
package junkfile

import (
	"context"
	"io/fs"
	"path/filepath"
	"slices"
	"strings"
	"time"

	"github.com/Shougo/goda-fi.vim/ext/kind/file"
	"github.com/Shougo/goda-fi.vim/fi"
	"github.com/Shougo/goda.vim/sdk"
)

type source struct{ now func() time.Time }

// New returns the source.
func New() fi.Source { return source{now: time.Now} }

func (source) Name() string { return "junkfile" }
func (source) Kind() string { return "file" }

func (s source) Gather(ctx context.Context, h sdk.Host, a fi.GatherArgs, emit func([]fi.Item) error) error {
	// The directory of this month, as junkfile#open() makes it.
	if _, err := h.Call(ctx, "junkfile#init"); err != nil {
		return err
	}
	r, err := h.Eval(ctx, "expand(g:junkfile#directory)")
	if err != nil {
		return err
	}
	dir, _ := r.(string)
	if dir == "" {
		return nil
	}

	// A new junk file: {directory}/%Y/%m/%Y-%m-%d-%H%M%S.{input}
	name := s.now().Format("2006/01/2006-01-02-150405.") + a.Input
	base := filepath.Base(name)
	items := []fi.Item{{
		Word:    base,
		Display: "[new] " + base,
		Action:  file.ActionData{Path: filepath.Join(dir, filepath.FromSlash(name))},
	}}

	var files []fi.Item
	err = filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			if path == dir {
				return err
			}
			return nil
		}
		if d.IsDir() {
			return nil
		}
		rel, err := filepath.Rel(dir, path)
		if err != nil {
			return nil
		}
		it := fi.Item{Word: filepath.ToSlash(rel), Action: file.ActionData{Path: path}}
		if info, err := d.Info(); err == nil {
			it.Status = &fi.Status{Size: info.Size(), Time: info.ModTime().UnixMilli()}
		}
		files = append(files, it)
		return nil
	})
	if err != nil {
		return err
	}
	// The latest first: the names start with their date.
	slices.SortFunc(files, func(a, b fi.Item) int { return strings.Compare(b.Word, a.Word) })
	return emit(append(items, files...))
}
