import { type Item } from "@shougo/ddu-vim/types";
import { BaseSource } from "@shougo/ddu-vim/source";
import { type ActionData } from "@shougo/ddu-kind-file";

import type { Denops } from "@denops/std";
import * as vars from "@denops/std/variable";
import * as fn from "@denops/std/function";

import { join } from "@std/path/join";
import { basename } from "@std/path/basename";
import { relative } from "@std/path/relative";

type Params = Record<string, never>;

export class Source extends BaseSource<Params> {
  override kind = "file";

  override gather(args: {
    denops: Denops;
    sourceParams: Params;
    input: string;
  }): ReadableStream<Item<ActionData>[]> {
    return new ReadableStream({
      async start(controller) {
        await args.denops.call("junkfile#init");

        const dir = await fn.expand(
          args.denops,
          await vars.g.get(args.denops, "junkfile#directory"),
        ) as string;

        const tree = async (root: string) => {
          let items: Item<ActionData>[] = [];

          for await (const entry of Deno.readDir(root)) {
            const path = join(root, entry.name);
            if (!entry.isDirectory) {
              items.push({
                word: relative(dir, path),
                action: {
                  path: path,
                },
              });
            }

            if (entry.isDirectory) {
              items = items.concat(await tree(path));
            }
          }

          return items;
        };

        const newFilename = (await fn.strftime(
          args.denops,
          "%Y/%m/%Y-%m-%d-%H%M%S.",
        )) + args.input;

        let items: Item<ActionData>[] = [{
          word: basename(newFilename),
          display: `[new] ${basename(newFilename)}`,
          action: {
            path: join(dir, newFilename),
          },
        }];
        items = items.concat((await tree(dir)).sort(
          (a, b) => a.word < b.word ? 1 : a.word == b.word ? 0 : -1,
        ));

        controller.enqueue(items);

        controller.close();
      },
    });
  }

  override params(): Params {
    return {};
  }
}
