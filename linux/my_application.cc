#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <iostream>
#include <cstring>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include "flutter/generated_plugin_registrant.h"
#include <vector>

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static GtkWindow *window = nullptr;

// static void respond(FlMethodCall *method_call, FlMethodResponse *response) {
//   g_autoptr(GError) error = nullptr;
//   if (!fl_method_call_respond(method_call, response, &error)) {
//     g_warning("Failed to send method call response: %s", error->message);
//   }
// }

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call, gpointer user_data) {
  // const gchar *method = fl_method_call_get_name(method_call);
  // const FlValue *args = fl_method_call_get_args(method_call);

  // if (strcmp(method, "focusable") == 0) {
  //   FlValue *focusable = fl_value_lookup_string(args, "focusable");
  //
  //   if (focusable != nullptr && fl_value_get_type(focusable) == FL_VALUE_TYPE_BOOL) {
  //     gtk_layer_set_keyboard_mode(window, fl_value_get_bool(focusable) ? GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND : GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
  //     g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(rl_method_success_response_new(fl_value_new_null()));
  //     respond(method_call, response);
  //     return;
  //   }
  // }

  g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  g_autoptr(GError) error = nullptr;
  fl_method_call_respond(method_call, response, &error);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  GList *list = gtk_application_get_windows(GTK_APPLICATION(application));
  GtkWindow* existing_window = list ? GTK_WINDOW(list->data) : NULL;

  if (existing_window) {
    gtk_window_present(existing_window);
    return;
  }

  window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  gboolean use_header_bar = FALSE;
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Flarrent");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Flarrent");
  }

  GdkScreen* gdkScreen;
  GdkVisual* visual;
  gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);
  gdkScreen = gdk_screen_get_default();
  visual = gdk_screen_get_rgba_visual(gdkScreen);
  if (visual != NULL && gdk_screen_is_composited(gdkScreen)) {
    gtk_widget_set_visual(GTK_WIDGET(window), visual);
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FlEngine *engine = fl_view_get_engine(view);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlBinaryMessenger) messenger = fl_engine_get_binary_messenger(engine);
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(messenger, "general", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb, g_object_ref(view), g_object_unref);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static void send_torrents(char** arguments) {
  std::vector<std::string> torrentArgs;

  for (int i = 0; arguments[i] != NULL; i++) {
    const char* argument = arguments[i];

    if (strcmp(argument, "--torrent") == 0 && arguments[i + 1] != NULL) {
        torrentArgs.push_back(arguments[i + 1]);
    }
  }

  // Create a socket
  int sockfd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (sockfd == -1) {
      perror("socket");
      return;
  }

  // Set up the server address structure
  struct sockaddr_un server_address;
  server_address.sun_family = AF_UNIX;
  strcpy(server_address.sun_path, "/tmp/flarrent.sock");

  // Connect to the server
  if (connect(sockfd, (struct sockaddr*)&server_address, sizeof(server_address)) == -1) {
      perror("connect");
      close(sockfd);
      return;
  }

  for (const std::string& argument : torrentArgs) {
    // Data to send
    const std::string message = "torrent " + argument;

    // Send the data
    send(sockfd, message.c_str(), message.length(), 0);
    send(sockfd, ";", 1, 0);
  }

  // Close the socket
  close(sockfd);
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);

  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  if (g_application_get_is_remote(application)) {
    send_torrents(self->dart_entrypoint_arguments);
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     nullptr));
}
