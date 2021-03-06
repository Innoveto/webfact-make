<?php

function webfactp_install_tasks() {
  $task['machine_name'] = array(
    'display_name' => st('Set theme'),
    'display' => TRUE,
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
    'function' => 'webfactp_set_theme',
  );
  return($task);
}

function webfactp_set_theme() {
  $enable = array(
    'theme_default' => 'bootstrap',
    'admin_theme' => 'seven',
  );
  theme_enable($enable);

  foreach ($enable as $var => $theme) {
    if (!is_numeric($var)) {
      variable_set($var, $theme);
    }
  }
  // Disable the default Bartik theme
  theme_disable(array('bartik'));

/*
  // disable search block
  $blocks = array(
    array(
      'module' => 'search',
      'delta' => 'form',
      'theme' => $default_theme,
      'status' => 0,    // disable
      'weight' => -1,
      'region' => 'sidebar_first',
      'pages' => '',
      'cache' => -1,
    ),
  );
  $query = db_insert('block')->fields(array('module', 'delta', 'theme', 'status', 'weight', 'region', 'pages', 'cache'));
  foreach ($blocks as $block) {
    $query->values($block);
  }
  $query->execute();
*/

  // settings: performance
  variable_set('page_compression', '1');
  variable_set('preprocess_css', '1');
  variable_set('preprocess_js', '1');
  variable_set('cache', 1);

  variable_set('jquery_update_compression_type', 'min');
  variable_set('jquery_update_jquery_cdn', 'google');

  // add a front page node
  $node = new stdClass();
  $node->type = 'page';
  $node->uid = 1;
  $node->status = 1;
  $node->title = 'Welcome';
  $node->path = array('alias' => 'welcome');
  //$node->promote = 0;
  $node->language = LANGUAGE_NONE;
  $node->body[$node->language][0]['value']='The webfactory allows creation of micro websites thanks to Docker and Drupal';
  node_save($node);
  variable_set('site_frontpage', 'node/1');


  // other settings
  variable_set('file_private_path', '/var/lib/drupal-private');
  variable_set('file_temporary_path', '/tmp');

  // disabled unneeded modules
  module_disable(array('rdf', 'color', 'overlay'));

  // can enable the feature here, but not in the .info. strange
  module_enable(array('webfact_content_types'));

  // add a template
  $node = new stdClass();
  $node->type = 'template';
  $node->uid = 1;
  $node->title = 'Plain Drupal7';
  $node->language = LANGUAGE_NONE;
  $node->body[$node->language][0]['value']='Vanilla Drupal 7';
  $node->field_docker_image['und'][0]['value'] = 'boran/drupal';
  node_save($node);
  $templateid = $node->nid;

  // add a website
  $node = new stdClass();
  $node->type = 'website';
  $node->uid = 1;
  $node->title = 'vanilla';
  $node->language = LANGUAGE_NONE;
  $node->body[$node->language][0]['value']='First website container called vanilla using the boran/drupal image from the template Plain Drupal7';
  $node->field_hostname['und'][0]['value'] = 'vanilla';
  //$node->field_docker_image['und'][0]['value'] = 'boran/drupal';   // could directly specify the image
  $node->field_template['und'][0]['target_id'] = $templateid; // link to template
  node_save($node);

}


/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function webfactp_form_install_configure_form_alter(&$form, $form_state) {
  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
}

?>
