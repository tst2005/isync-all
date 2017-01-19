# isync all

# what is missing in isync ?

* `isync` is able to get all folders (see the `-a` option) but it seems limited to one level.

# what is isync-account

* `isync-account` implement a kind of `find` to walk on the tree of folders to really get them all.
* `isync-account` is made to support only one email account.

# what is isync-all-accounts

* `isync-all-accounts` simply run `isync-account` for each config found in the `config.d/` folders.


# TODO

* rename and refactor the `isync-account` code
* merge `isync-all-accounts` into `isync-account` (need more option)
* improve the log and alert stuff
