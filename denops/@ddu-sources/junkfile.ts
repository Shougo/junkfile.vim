import {
  BaseSource,
  Item,
} from "https://deno.land/x/ddu_vim@v0.7.1/types.ts#^";
import { Denops, fn, vars } from "https://deno.land/x/ddu_vim@v0.7.1/deps.ts#^";
import { join } from "https://deno.land/std@0.125.0/path/mod.ts";
import { ActionData } from "https://deno.land/x/ddu_kind_file@v0.1.0/file.ts#^";
import { relative } from "https://deno.land/std@0.122.0/path/mod.ts#^";

type Params = Record<string, never>;

export class Source extends BaseSource<Params> {
  kind = "file";

  gather(args: {
    denops: Denops;
    sourceParams: Params;
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

        controller.enqueue(await tree(dir));

        controller.close();
      },
    });
  }

  params(): Params {
    return {};
  }
}
