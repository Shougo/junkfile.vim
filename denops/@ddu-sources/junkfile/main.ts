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

        const collectItems = async (
          root: string,
        ): Promise<Item<ActionData>[]> => {
          const items: Item<ActionData>[] = [];

          for await (const entry of Deno.readDir(root)) {
            const path = join(root, entry.name);

            if (entry.isDirectory) {
              items.push(...await collectItems(path));
              continue;
            }

            items.push({
              word: relative(dir, path),
              action: {
                path,
              },
            });
          }

          return items;
        };

        const newFilename = `${await fn.strftime(
          args.denops,
          "%Y/%m/%Y-%m-%d-%H%M%S.",
        )}${args.input}`;
        const newBasename = basename(newFilename);

        const items: Item<ActionData>[] = [
          {
            word: newBasename,
            display: `[new] ${newBasename}`,
            action: {
              path: join(dir, newFilename),
            },
          },
          ...(await collectItems(dir)).sort((a, b) =>
            b.word.localeCompare(a.word)
          ),
        ];

        controller.enqueue(items);
        controller.close();
      },
    });
  }

  override params(): Params {
    return {};
  }
}
