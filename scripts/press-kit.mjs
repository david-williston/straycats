// Zips the brand kit (static/press/straycats-brand-kit/) into
// static/press/straycats-brand-kit.zip for the Press page's "Download everything" link.
// The zip is built, not committed (see .gitignore), so the images aren't stored twice.
// Run automatically by `npm run build`, `npm run dev` and both GitHub workflows.

import { execFileSync } from 'node:child_process';
import { rmSync } from 'node:fs';

const DIR = 'static/press';
const KIT = 'straycats-brand-kit';
const ZIP = `${KIT}.zip`;

rmSync(`${DIR}/${ZIP}`, { force: true });
// -X leaves out file attributes, so the same files make the same zip
execFileSync('zip', ['-qrX', ZIP, KIT, '-x', '*.DS_Store'], { cwd: DIR, stdio: 'inherit' });
console.log(`Wrote ${DIR}/${ZIP}`);
