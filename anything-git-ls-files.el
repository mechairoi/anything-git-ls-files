(require 'vc-git)
(require 'anything)
(provide 'anything-git-ls-files)

(defun anything-git-ls-files-find-git-root ()
  (vc-git-root (or (buffer-file-name) default-directory)))

(defun anything-c-source-git-ls-files-for (name command)
  `((name . ,name)
    (init
     . (lambda ()
         (anything-aif (with-current-buffer anything-current-buffer
                         (anything-git-ls-files-find-git-root))
             (let* ((default-directory it)
                    (buffer-name (anything-c-source-git-ls-files-candidate-buffer-name it))
                    (cached-buffer (get-buffer buffer-name)))
               (anything-attrset 'default-directory it)
               (let ((buffer (get-buffer-create buffer-name)))
                 (anything-candidate-buffer buffer)
                 (unless cached-buffer
                   (let ((process
                          (start-process-shell-command (concat default-directory anything-source-name)
                                                       buffer ,command)))
                     (set-process-sentinel process (lambda (proc msg) nil)) ;; to remove "finished" message
                     )))))))
    (display-to-real . (lambda (name) (expand-file-name name (anything-attr 'default-directory))))
    (candidates-in-buffer)
    (type . file)))

(defun anything-c-source-git-ls-files-candidate-buffer-name (dir)
  (format " *anything candidates:%s*%s*" anything-source-name dir))

(defvar anything-c-source-git-ls-files-modified
  (anything-c-source-git-ls-files-for
   "Git Modified Files"
   "git --no-pager ls-files --full-name --modified"))
(defvar anything-c-source-git-ls-files-untracked
  (anything-c-source-git-ls-files-for
   "Git Untracked Files"
   "git --no-pager status --short | grep '^??' | sed 's/^\?\? //'"))
(defvar anything-c-source-git-ls-files-added
  (anything-c-source-git-ls-files-for
   "Git Added Files"
   "git --no-pager status --short | grep '^[AM]' | sed 's/^[AM][M ] //'"))
(defvar anything-c-source-git-ls-files-cached
  (anything-c-source-git-ls-files-for
   "Git Cached Files"
   "git --no-pager ls-files --full-name --cached"))
(defvar anything-c-source-git-ls-files-others
  (anything-c-source-git-ls-files-for
   "Git Other Files"
   "git --no-pager ls-files --full-name --others"))

(defvar anything-c-source-git-submodule-ls-files-modified
  (anything-c-source-git-ls-files-for
   "Git Submodule Modified Files"
   "git --no-pager submodule --quiet foreach 'git ls-files --modified --full-name | sed s!^!$path/!'"))
(defvar anything-c-source-git-submodule-ls-files-untracked
  (anything-c-source-git-ls-files-for
   "Git Submodule Untracked Files"
   "git --no-pager submodule --quiet foreach 'git status --short | grep \"^??\" | sed \"s!^\?\? !!\" | sed s!^!$path/!'"))
(defvar anything-c-source-git-submodule-ls-files-added
  (anything-c-source-git-ls-files-for
   "Git Submodule Added Files"
   "git --no-pager submodule --quiet foreach 'git status --short | grep \"^[AM]\" | sed \"s!^[AM]  !!\" | sed s!^!$path/!'"))
(defvar anything-c-source-git-submodule-ls-files-cached
  (anything-c-source-git-ls-files-for
   "Git Submodule Cached Files"
   "git --no-pager submodule --quiet foreach 'git ls-files --cached --full-name | sed s!^!$path/!'"))
(defvar anything-c-source-git-submodule-ls-files-others
  (anything-c-source-git-ls-files-for
   "Git Submodule Other Files"
   "git --no-pager submodule --quiet foreach 'git ls-files --others --full-name | sed s!^!$path/!'"))

(defun anything-git-ls-files ()
  "Anything Git Ls-files"
  (interactive)
  (anything-other-buffer
   '(anything-c-source-git-ls-files-modified
     anything-c-source-git-ls-files-untracked
     anything-c-source-git-ls-files-added
     anything-c-source-git-ls-files-cached
     anything-c-source-git-ls-files-others)
   "*anything git ls-files*"))

(defun anything-git-submodule-ls-files ()
  "Anything Git Submodule Ls-files"
  (interactive)
  (anything-other-buffer
   '(anything-c-source-git-ls-files-modified
     anything-c-source-git-ls-files-untracked
     anything-c-source-git-ls-files-added
     anything-c-source-git-ls-files-cached
     anything-c-source-git-ls-files-others
     anything-c-source-git-submodule-ls-files-modified
     anything-c-source-git-submodule-ls-files-untracked
     anything-c-source-git-submodule-ls-files-added
     anything-c-source-git-submodule-ls-files-cached
     anything-c-source-git-submodule-ls-files-others)
   "*anything git submodule ls-files*"))
