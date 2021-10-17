const fs = require('fs-extra');
const shelljs = require('shelljs');
const { tDate, tEcho } = require('tmind-core');
try {
	shelljs.exec('git add .');
	shelljs.exec(`git commit -m "${tDate().format('YYYY-MM-DD hh:mi:ss')}"`);
	shelljs.exec('git push -u origin main');

	tEcho('Done!', '提交成功', 'SUCC');
} catch (err) {
	tEcho(err, '提交失败', 'ERR');
}
