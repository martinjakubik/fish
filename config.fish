function prompt_pwd --description 'Print the current working directory, NOT shortened to fit the prompt'
  if test "$PWD" != "$HOME"
    printf "%s" (echo $PWD|sed -e 's|/private||' -e "s|^$HOME|~|")
  else
    echo '~'
  end
end

function fish_prompt
  echo
  set_color ff55ff
  echo (whoami)' @ '(prompt_pwd)
  set_color normal
  echo '$ '
end

function ll --description "List contents of directory using long format"
    ls -la $argv
end

function encrypt
  gpg -c -a --cipher-algo AES256 $argv[1]
end

function decrypt
  gpg -d $argv[1]
end
