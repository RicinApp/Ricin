public errordomain Ricin.ErrPassword {
  Null,
  Weak,
  NotConfirmed,
  NotDifferent
}

public enum Ricin.PasswordDialogType {
  ADD_PASSWORD,
  EDIT_PASSWORD,
  REMOVE_PASSWORD
}

[GtkTemplate (ui="/chat/tox/ricin/ui/password-dialog.ui")]
public class Ricin.PasswordDialog : Gtk.Dialog {
  [GtkChild] Gtk.Label label_title;
  [GtkChild] Gtk.Label label_description;
  [GtkChild] Gtk.Label label_current_password;
  [GtkChild] Gtk.Entry entry_current_password;
  [GtkChild] Gtk.Label label_password;
  [GtkChild] Gtk.Entry entry_password;
  [GtkChild] Gtk.Label label_password_confirm;
  [GtkChild] Gtk.Entry entry_password_confirm;
  [GtkChild] Gtk.Label label_password_strength;
  [GtkChild] Gtk.LevelBar levelbar_password_strength;
  [GtkChild] Gtk.Button button_accept;
  [GtkChild] Gtk.Button button_reject;

  public new PasswordDialogType dtype { get; protected set; }
  public signal void resp (int response_id, string? password, string? old_password = null);

  public PasswordDialog (Gtk.Window? transient, string title, string description, PasswordDialogType type) {
    this.dtype = type;
    this.label_title.set_text (title);
    this.label_description.set_markup (description);

    this.set_transient_for (transient);
    this.set_size_request (450, 250);

    this.switch_mode ();
    this.init_signals ();
  }

  private void switch_mode () {
    if (this.dtype == PasswordDialogType.ADD_PASSWORD) {
      this.label_current_password.visible = false;
      this.entry_current_password.visible = false;
    } else if (this.dtype == PasswordDialogType.EDIT_PASSWORD) {
      // Do nothing yet.
    } else if (this.dtype == PasswordDialogType.REMOVE_PASSWORD) {
      this.label_password.visible = false;
      this.entry_password.visible = false;
      this.label_password_confirm.visible = false;
      this.entry_password_confirm.visible = false;
      this.label_password_strength.visible = false;
      this.levelbar_password_strength.visible = false;
    }

    //this.button_accept.sensitive = false;
  }

  private void init_signals () {
    this.button_accept.clicked.connect (() => {
      try {
        this.validate ();
      } catch (ErrPassword e) {
        this.label_description.set_markup ("<span color=\"#e74c3c\">" + e.message + "</span>");
        return;
      }

      if (this.dtype == PasswordDialogType.ADD_PASSWORD) {
        this.resp (Gtk.ResponseType.ACCEPT, this.entry_password.get_text ());
      } else if (this.dtype == PasswordDialogType.EDIT_PASSWORD) {
        this.resp (
          Gtk.ResponseType.ACCEPT,
          this.entry_current_password.get_text (),
          this.entry_password.get_text ()
        );
      } else if (this.dtype == PasswordDialogType.REMOVE_PASSWORD) {
        this.resp (Gtk.ResponseType.ACCEPT, this.entry_current_password.get_text ());
      }
    });
    this.button_reject.clicked.connect (() => {
      this.resp (Gtk.ResponseType.CANCEL, null);
    });
  }

  private bool validate () throws ErrPassword {
    var current_pass = this.entry_current_password.get_text ();
    var pass = this.entry_password.get_text ();
    var pass_confirm = this.entry_password_confirm.get_text ();

    if (this.dtype == PasswordDialogType.ADD_PASSWORD) {
      if (pass != pass_confirm) {
        throw new ErrPassword.NotConfirmed (_("Password doesn't match confirmation."));
      }
      if (pass.length < 8) {
        throw new ErrPassword.Weak (_("Password must be at least 8 characters."));
      }
      if (pass.strip () == "") {
        throw new ErrPassword.Null (_("Password cannot be blank."));
      }
      if (pass_confirm.strip () == "") {
        throw new ErrPassword.Null (_("Password confirmation cannot be blank."));
      }
    } else if (this.dtype == PasswordDialogType.EDIT_PASSWORD) {
      if (current_pass == pass) {
        throw new ErrPassword.NotDifferent (_("New password must be different from the older one."));
      }
      if (pass != pass_confirm) {
        throw new ErrPassword.NotConfirmed (_("Password doesn't match confirmation."));
      }
      if (pass.length < 8) {
        throw new ErrPassword.Weak (_("Password must be at least 8 characters."));
      }
      if (pass.strip () == "") {
        throw new ErrPassword.Null (_("Password cannot be blank."));
      }
      if (pass_confirm.strip () == "") {
        throw new ErrPassword.Null (_("Password confirmation cannot be blank."));
      }
      if (current_pass.strip () == "") {
        throw new ErrPassword.Null (_("Current password cannot be blank."));
      }
    } else if (this.dtype == PasswordDialogType.REMOVE_PASSWORD) {
      if (current_pass.length < 8) {
        throw new ErrPassword.Weak (_("Password must be at least 8 characters."));
      }
      if (current_pass.strip () == "") {
        throw new ErrPassword.Null (_("Password cannot be blank."));
      }
    }

    return true;
  }

  [GtkCallback]
  private void compute_strength () {
    ;
  }
}
