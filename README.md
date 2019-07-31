# GuestBook-helm

This is an example charts repository.

How It Works

I set up GitHub Pages to point to the docs folder. From there, I can create and publish docs like this:





```
$ helm create guestbook
$ helm package guestbook
$ mv guestbook-0.1.0.tgz docs
$ helm repo index docs --url https://akhilrajmailbox.github.io/GuestBook/docs
$ git add -i
$ git commit -av
$ git push origin master
```

add helm repo to your system and install.
```
helm repo add helm-repo https://akhilrajmailbox.github.io/GuestBook/docs
```