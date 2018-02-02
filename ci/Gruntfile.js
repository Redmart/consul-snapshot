"use strict";
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    gopath: process.env.GOPATH,
    source: '<%= gopath %>/bin/',
    project_name: '<%= pkg.name.replace(/-/g, "_") %>',
    archive_name: '<%= pkg.name%>-<%= pkg.version %>.zip',
    artifact_name: 'current.zip',       // `current.zip` by default. (optional)
    release: {
        options: {
            commit: false,
            tag: false,
            push: false,
            pushTags: false,
            npm: false,
          additionalFiles: ['../bower.json', '../package.json']
          }
      },
    redmart_builder: {
      options: {
        archivePath: '../', // path to your `archive` file (optional)
        // clean: { },      // if anything needs to be cleaned before compression
        // compress: { },   // if anything needs to be compressed
        triggerChef: true,
        compress: {
          main1: {
            options: {
              archive: '../<%= archive_name %>'
            },
            files: [
              {src: ['**'], cwd: '<%= source %>', dest: '/', expand: true}
            ]
          },
          main2: {
            options: {
              archive: '../<%= artifact_name %>'
            },
            files: [
              {src: ['**'], cwd: '<%= source %>', dest: '/', expand: true}
            ]
          }
        }
        //chef: {
        //  async: true,        // default false
          // attributes: '--override-runlist \"recipe[redmart_console::deploy]\"'
        //}
      }
    }
  });

  grunt.loadNpmTasks('semvar-ghflow-grunt-redmart-builder');
  grunt.loadNpmTasks('grunt-release');
  grunt.registerTask('default', 'redmart_builder');
};
