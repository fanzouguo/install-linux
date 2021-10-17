const { tEcho, tClear, smpoo, tDate } = require('tmind-core');
const fs = require('fs-extra');
const path = require('path');
const inquirer = require('inquirer');
const shelljs = require('shelljs');
const { series } = require('gulp');

const VER_POLICY = {
	major: 0,
	minor: 1,
	build: 2
};
// 发布备选问题
const SETP_QUESTION = {
	// 1、版本策略
	'#001': {
		name: 'VER_POLICY',
		type: 'list',
		message: '请选择版本更新策略',
		default: 'build',
		choices: [
			'major',
			'minor',
			'build'
		]
	},
	// 2、输入提交备注
	'#002': {
		type: 'input',
		message: '请输入提交备注',
		name: 'GIT_MEMO'
	},
	// 2、输入GIT分支
	'#003': {
		type: 'input',
		message: '请输入GIT分支',
		name: 'GIT_BRANCH',
		default: 'main'
	},
	// 3、是否创建 tag 标签
	'#004': {
		type: 'confirm',
		message: '是否根据该版本创建 tag 标签',
		name: 'TAG_THIS',
		default: false
	}
};
// 各步骤值记录
const SETP_VAL = {
	// 版本策略
	'#001': 'build',
	// 本次提交备注
	'#002': '',
	// git分支
	'#003': 'main',
	// 是否创建 tag 标签
	'#004': false
};

const BUILD_OPT = {
	// 本次构建的程序名称
	NAME_APP: '',
	// package.json 文件名
	NAME_FILE_PKG: 'package.json',
	// tmind-cli 配置参数文件名
	NAME_FILE_TMIND: '.tMind',
	// 工作区全局仓库安装路径
	PATH_REPO: '',
	// 依赖包的版本号
	VER_DEPEND: {},
	// 构建前的版本号
	VER_BEFORE: '',
	// 当前构建项目的 package.json
	CURR_PKG: {},
	// 本次构建要执行的 github 指令集
	CMD_GIT: [],
	// 当前 package.json 配置中是否允许发布到npm
	PUB_ALLOW: false,
	// 本次 NPM 的发布是否成功
	PUB_SUCC: false,
	/** 本项目所依赖的关键包
	 *
	 */
	LIST_PKG_DEPEND: [],
	/** 要拷贝的静态资源列表
	 *
	 */
	LIST_FILE_COPY: [],
	/** .dev/conf环境是否需要重新初始化
	 *
	 */
	NEED_EVN: false,
	/** 发布后，回装模式
	 *
	 */
	YARN_TYPE: 'yarn add',
	/** 是否允许上传到 npmjs
	 *
	 */
	ALLOW_PUBLISH: false
};

// 显示控制
const echo = {
	// 行分割线显示
	tLine: str => {
		const _str = str ? `${str}` : '';
		tEcho(`\n--------------------------------------${_str}--------------------------------------\n`);
	},
	// 行信息显示
	tRow: (msg, title, type = 'INFO') => {
		tEcho('\n');
		// @ts-ignore
		tEcho(msg, title || '', type);
	},
	// 路径格式化器
	pathFormatter: (str) => str.replace(/\\\\|\\/g, '/'),
	/** 终止器
	 * @param {*} msg 退出前的提示信息
	 * @param {*} title 控制台显示时的标签
	 * @param {*} code 进程退出码
	 */
	terminate: (msg, title = '', code = 1) => {
		tEcho(msg || '', title || '', 'ERR');
		process.exit(code);
	}
};
/** 发起交互提问
 *
 * @param {*} code 问题码
 */
const qsExecer = async code => {
	try {
		const _obj = SETP_QUESTION[code];
		if (_obj) {
			const { depend, ...otherDef } = _obj;
			if (!depend || (depend && depend())) {
				const res = await inquirer.prompt(otherDef);
				SETP_VAL[code] = res[_obj.name];
			}
		} else {
			return '#done';
		}
	} catch (err) {
		echo.terminate(err.message);
	}
};

function* questions(needEnv) {
	if (needEnv) {
		yield qsExecer('EVT');
		BUILD_OPT.NEED_EVN = false;
	}
	const val = Object.keys(SETP_QUESTION).length + 1;
	for (let i = 0; i < val; i++) {
		yield qsExecer(`#00${i}`);
	}
}

/** 异步写入文件
 *
 * @param fName 含文件名的路径
 * @param fData 要写入文件的数据
 * @returns
 */
const writeFile = async (fName, fData) => {
	return new Promise((resolve, reject) => {
		fs.writeFile(fName, fData, err => {
			if (err) reject(err);
			resolve('');
		});
	});
};

class PathMgr {
	constructor() { }

	/** 获取路径
	 *
	 * @param basePath 根路径，如果为空字符或 nullLike 则代表 process.cwd
	 * @param suffix 子路径
	 * @returns
	 */
	static getPath(basePath, ...suffix) {
		return echo.pathFormatter(path.resolve((basePath || process.cwd()), ...suffix));
	}

	/** 读取指定根路径下的 JSON 文件
	 *
	 * @param basePath 根路径，如果为空字符或 nullLike 则代表 process.cwd
	 * @param suffix 子路径
	 * @returns
	 */
	static getJsonFile(basePath, ...suffix) {
		return fs.readJSONSync(this.getPath(basePath, ...suffix));
	}

	/** 读取指定根路径下的 package.json 文件
	 *
	 * @param basePath 根路径，如果为空字符或 nullLike 则代表 process.cwd
	 * @returns
	 */
	static getPackageJson(basePath) {
		return this.getJsonFile(basePath, BUILD_OPT.NAME_FILE_PKG);
	}

	/** 读取指定根路径下的指定文件
	 *
	 * @param basePath 根路径，如果为空字符或 nullLike 则代表 process.cwd
	 * @param suffix
	 * @returns
	 */
	static getFile(basePath, ...suffix) {
		return fs.readFileSync(this.getPath(basePath, ...suffix)).toString();
	}
}
// 0、环境和变量准备
const STEP_0_Ask = async cb => {
	tClear();
	echo.tRow('', '初始化...');
	const execer = questions(BUILD_OPT.NEED_EVN);
	for (const v of execer) {
		await v;
	}
	cb();
};

// 4、更新 package.json 版本号和依赖包版本
const STEP_4_UpPkg = async cb => {
	echo.tRow('', '重写版本号...');
	const _offset_ = VER_POLICY[SETP_VAL['#001']];
	const verArr = BUILD_OPT.VER_BEFORE.split('.').map(v => parseInt(v));
	// @ts-ignore
	const newVerArr = verArr.map((v, k) => {
		if (k === _offset_) {
			v++;
		} else if (k > _offset_) {
			v = 0;
		}
		return v;
	});
	// verArr[_offset_] = verArr[_offset_] + 1;
	BUILD_OPT.CURR_PKG.version = newVerArr.join('.');
	for (const v in BUILD_OPT.VER_DEPEND) {
		if (BUILD_OPT.CURR_PKG.dependencies[v]) {
			// @ts-ignore
			BUILD_OPT.CURR_PKG.dependencies[v] = BUILD_OPT.VER_DEPEND[v];
		} else if (BUILD_OPT.CURR_PKG.devDependencies[v]) {
			// @ts-ignore
			BUILD_OPT.CURR_PKG.devDependencies[v] = BUILD_OPT.VER_DEPEND[v];
		}
	}
	await writeFile(PathMgr.getPath('', BUILD_OPT.NAME_FILE_PKG), JSON.stringify(BUILD_OPT.CURR_PKG, null, 2));
	cb();
};
// 5、提交 git Hub
const STEP_5_SaveToGit = async cb => {
	echo.tRow('', '提交GitHub...');
	BUILD_OPT.CMD_GIT.push('git add .');
	const regRule = new RegExp('^[a-zA-Z]');
	let memoStr = SETP_VAL['#002'];
	if (regRule.test(memoStr)) {
		memoStr = `${memoStr}`.upFirst();
	}
	const _tagThis_ = SETP_VAL['#004'];
	if (_tagThis_) {
		BUILD_OPT.CMD_GIT.push(`git tag -a v${BUILD_OPT.CURR_PKG.version} -m "${memoStr}"`);
	}
	BUILD_OPT.CMD_GIT.push(`git commit -m "(${tDate().format('YYYY-MM-DD hh:mi:ss')})${memoStr}"`);
	if (_tagThis_) {
		BUILD_OPT.CMD_GIT.push('git push origin --tags');
	}

	if (BUILD_OPT.CURR_PKG?.repository?.url) {
		BUILD_OPT.CMD_GIT.push(`git push -u origin ${SETP_VAL['#003']}`);
	} else {
		tEcho('本项目未关联 gitHub 仓库', '提示', 'WARN');
	}

	for (const v of BUILD_OPT.CMD_GIT) {
		// @ts-ignore
		shelljs.exec(v, {
			async: false
		});
	}
	cb();
};
// 完成
const STEP_Done = cb => {
	const { consoleStr } = smpoo();
	// @ts-ignore
	tEcho(consoleStr());
	tEcho('\n');
	echo.tLine(`  ${BUILD_OPT.NAME_APP} 构建完成  `);
	tEcho(`${BUILD_OPT.CURR_PKG.description || '无描述'}\n`);
	tEcho('', `当前版本：v${BUILD_OPT.VER_BEFORE} —> v${BUILD_OPT.CURR_PKG.version}`, 'INFO');
	echo.tLine('--------------------------');
	tEcho('', '构建完成', 'SUCC');
	if (BUILD_OPT.PUB_ALLOW && BUILD_OPT.PUB_SUCC) {
		tEcho('\n');
		tEcho('发布完成，请注意更改引用该包的程序的 package.json 中申明的版本号！\n\n\n\n', '注意！！！', 'WARN');
	}
	const appName = BUILD_OPT.CURR_PKG.name;
	// @ts-ignore
	shelljs.exec(`yarn list ${appName}`);
	process.exit();
}

const execBuild = () => {
	return series(
		STEP_0_Ask,
		STEP_4_UpPkg,
		STEP_5_SaveToGit,
		STEP_Done
	);
}

execBuild()();