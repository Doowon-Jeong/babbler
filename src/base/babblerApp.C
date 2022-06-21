#include "babblerApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
babblerApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  return params;
}

babblerApp::babblerApp(InputParameters parameters) : MooseApp(parameters)
{
  babblerApp::registerAll(_factory, _action_factory, _syntax);
}

babblerApp::~babblerApp() {}

void
babblerApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"babblerApp"});
  Registry::registerActionsTo(af, {"babblerApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
babblerApp::registerApps()
{
  registerApp(babblerApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
babblerApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  babblerApp::registerAll(f, af, s);
}
extern "C" void
babblerApp__registerApps()
{
  babblerApp::registerApps();
}
