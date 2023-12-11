# BookGPT
A Rails + React adaptation of [Ask My Book](https://github.com/slavingia/askmybook).

BookGPT uses Retrieval Augmented Generation to answer questions about [The Mom Test](https://www.momtestbook.com/) by Rob Fitzpatrick.

Check it out at https://book-gpt-yjbf.onrender.com/.

# Tech stack
- Back-end - Rails
- Front-end - React and TypeScript
- Database - Postgres
- Hosting/Platform-as-a-Service - Render

# Local setup
First, install and run Postgres and its `pgvector` extension. Eg on OSX:
1. `brew install postgresql pgvector`
1. `brew services start postgresql`

On Apple's new ARM machines you may need to build the Postgres C client library `libpq` from source and tell bundler where to find the corresponding config file when installing the `pg` gem:
1. `brew install libpq --build-from-source`
1. Find the path to libpq: `find /opt/homebrew/Cellar -name pg_config | grep libpq`
1. `bundle config build.pg --with-pg-config=/opt/homebrew/Cellar/libpq/16.1_1/bin/pg_config`

Then:
1. `git clone git@github.com:Murphydbuffalo/bookgpt.git`
1. `cd bookgpt`
1. `touch .env` and add your OpenAI API key to it as `OPENAI_API_KEY`.
1. `bundle`
1. `bundle exec rails db:create`
1. `bundle exec rails db:migrate`
1. `npm install`
1. In a rails console or via `rails runner` run `BookPassage.import!(filepath: path_to_pdf_of_book)` to generate and store the embeddings of the book passages.
1. In one process: `bundle exec rails server`
1. In another: `./bin/vite dev` to watch the front-end files for changes and compile them on the fly. You can also run `./bin/vite build` to build the assets in the same way they'll be built on prod (via esbuild, walking the entire module graph, rather than doing incremental updates).
1. Visit localhost:3000

If everything worked you're now ready to ask questions about The Mom Test!

## TypeScript
Run `npm tsc --noEmit --watch` to run the type checker. Because [Vite is not designed](https://vitejs.dev/guide/features.html#typescript) to crawl the entire module graph during development they intentionally did not include the capability for the dev server to run type checking:
>Note that Vite only performs transpilation on .ts files and does NOT perform type checking. It assumes type checking is taken care of by your IDE and build process.

>The reason Vite does not perform type checking as part of the transform process is because the two jobs work fundamentally differently. Transpilation can work on a per-file basis and aligns perfectly with Vite's on-demand compile model. In comparison, type checking requires knowledge of the entire module graph. Shoe-horning type checking into Vite's transform pipeline will inevitably compromise Vite's speed benefits.

Given that, we have to run our own `tsc` command to get type checking.
