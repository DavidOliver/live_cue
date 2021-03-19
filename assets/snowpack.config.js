// Snowpack Configuration File
// See all supported options: https://www.snowpack.dev/reference/configuration

module.exports = {
	mount: {
		'js': { url: '/js' },
		'css': { url: '/css' },
		'static': { url: '/', static: true, resolve: false }
	},
	buildOptions: {
		out: '../priv/static'
	},
};
