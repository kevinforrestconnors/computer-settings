(require 'package) 
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) 

(push "~/.emacs.d/elpa/merlin-20160229.628/" load-path) ; directory containing merlin.el
(setq merlin-command "~/usr/local/bin/")  ; needed only if ocamlmerlin not already in your PATH
(autoload 'merlin-mode "merlin" "Merlin mode" t)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(add-hook 'caml-mode-hook 'merlin-mode)
