const fs = require('fs-extra');
const path = require('path');
const shelljs = require('shelljs');
const readline = require('readline');

// ask question from input
const getAnswer = question => {
	return new Promise((resolve, reject) => {
		const rl = readline.createInterface({
			input: process.stdin,
			output: process.stdout
		});
		rl.question(question, answer => {
			rl.close();
			resolve(answer);
		});
	});
};

/** 更新版本号 */
const setVer = async () => {
	const pkgPath = path.resolve(process.cwd(), 'package.json');
	const pkg = await fs.readJson(pkgPath, {
		encoding: 'utf8'
	});
	const oldVer = pkg.version;
	console.log(`当前版本号：${oldVer}`);

	const verPolice = await getAnswer('请选择版本策略：1) 更改主版本号 / 2) 子版本号 / 3 或回车) 修订号 -->');
	const [a, b, c] = `${oldVer}`.split('.').map(v => +v);
	const _arr = [];
	const answer = +verPolice;
	if (answer === 1) {
		_arr.push(a+1, 0, 0);
	}	else if (answer === 2) {
		_arr.push(a, b + 1, 0);
	} else {
		_arr.push(a, b, c + 1);
	}
	const newVer = _arr.join('.');
	pkg.version = newVer;
	await fs.writeJson(pkgPath, pkg, {
		encoding: 'utf8',
		spaces: 2
	});
	await updateReadme(oldVer, newVer);
	return newVer;
};

const getStr = verStr => `/install-linux@${verStr}/script/init.sh`;
const updateReadme = async (verOld, verNew) => {
	const pathReadme = path.resolve(process.cwd(), 'README.md');
	const readmeFileStr = await fs.readFile(pathReadme, {
		encoding: 'utf8'
	});
	const regStr = new RegExp(getStr(verOld), 'g');
	fs.writeFile(pathReadme, readmeFileStr.replace(regStr, getStr(verNew)));
};

// 5、提交 git Hub
const execBuild = async () => {
	console.clear();
	console.log('准备提交GitHub...');
	const currVer = await setVer();
	const memoCommit = await getAnswer('请输入提交备注：');
	const cmdStr = [
		'git add .',
		`git tag -a v${currVer} -m "${memoCommit}"`,
		`git commit -m "${memoCommit}"`,
		'git push origin --tags',
		'git push -u origin main'
	];

	for (const v of cmdStr) {
		shelljs.exec(v, {
			async: false
		});
	}

	console.log('Done!');
};

execBuild();
