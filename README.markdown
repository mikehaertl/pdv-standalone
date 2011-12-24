# PDV standalone

This is a standalone version of Tobias Schlitt's famous phpDocumentor for Vim plugin.

I was pretty happy with Tobias' original plugin (thanks Tobias!) but i had two issues
with it:

 * You had to alter the code to configure the plugin
 * Tobias integrated the latest version into his new VIP (VIM integration for PHP)
repository but i didn't need/want the rest in there

If you prefer Tobias' original repo, you find it at [tobyS/vip](https://github.com/tobyS/vip).

## Installation

You can just download the `pdv-standalone.vim` file and move it to your `~/.vim/plugin`
directory. But i'd rather recommend to use a plugin manager like [gmarik/vundle](https://github.com/gmarik/vundle).

## Configuration

It's recommended to map some keys to PDV. Personally i prefer `<C-K>`:

```vim
nnoremap <C-K> :call PhpDocSingle()<CR>
vnoremap <C-K> :call PhpDocRange()<CR>
```

As some tags are turned off by default, you should then add default values
for them:

```vim
let g:pdv_cfg_Package = 'placeholder'
let g:pdv_cfg_Version = '1.0.0'
let g:pdv_cfg_Author = 'Your Name <your.name@example.com>'
let g:pdv_cfg_Copyright = 'Copyright 2011 by Your Name <your.name@example.com>'
let g:pdv_cfg_License = 'Provided under the GPL (http://www.gnu.org/copyleft/gpl.html)'
```

Here's the full list of configuration options:

### Class level tags:

* `g:pdv_cfg_Package`: Value of `@package` tag. Defaults to `""` which means off.
* `g:pdv_cfg_Version`: Value of `@version` tag. Defaults to `""` which means off.
* `g:pdv_cfg_Author`: Value of `@author` tag. Defaults to `""` which means off.
* `g:pdv_cfg_Copyright`: Value of `@copyright` tag. Defaults to `""` which means off.
* `g:pdv_cfg_License`: Value of `@license` tag. Defaults to `""` which means off.

### Function tags:

* `g:pdv_cfg_ReturnVal`: Value of `@return` tag. Defaults to `"void"`. Use `""` to create no return tag.

### Options:

* `g:pdv_cfg_Type`: Default type of attributes and parameters. Defaults to `"mixed"`.
* `g:pdv_cfg_Uses`: Wether to create `@uses` tags. Defaults to 0 (off).
* `g:pdv_cfg_paste`: Wether to `:set paste` before documenting. Defaults to 1 (on).
* `g:pdv_cfg_php4always`: Wether PHP4 tags should be set, like `@access`. Defaults to 0 (off).
* `g:pdv_cfg_php4guess`: Wether to guess scopes from names (`$_foo`/`_bar()`). Defaults to 1 (on).
* `g:pdv_cfg_php4guessval`: Default scope for matches of `g:pdv_cfg_php4guess`. Defaults to `"protected"`.

### Docblock formatting

* `g:pdv_cfg_CommentHead`: Start of any comment block. Defaults to `"/**"`
* `g:pdv_cfg_Comment1`: Comment prefix of 1st line after start. Defaults to `" * "`
* `g:pdv_cfg_Commentn`: Comment prefix of remaining lines. Defaults to `" * "`
* `g:pdv_cfg_CommentTail`: End of any comment block. Defaults to `" */"`
* `g:pdv_cfg_CommentSingle`: Single line comment prefix. Defaults to `"//"`
