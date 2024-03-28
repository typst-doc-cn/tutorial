

#let iterate-scope(env, scope, belongs) = {
  let p = (..scope.path, scope.name).join(".")
  scope.insert("belongs", belongs)
  env.scoped-items.insert(p, scope)
  
  if "scope" in scope {
    let belongs = (kind: "scope", name: scope.name)
    for c in scope.scope {
      env = iterate-scope(env, c, belongs)
    }
  }
  
  return env
}

#let iterate-docs(env, route, path) = {
  if route.body.kind == "func" {
    env.funcs.insert(route.body.content.name, route)
  } else if route.body.kind == "type" {
    env.types.insert(route.body.content.name, route)
    
    // iterate-scope()
    if "scope" in route.body.content {
      let belongs = (kind: "type", name: route.body.content.name)
      for c in route.body.content.scope {
        env = iterate-scope(env, c, belongs)
      }
    }
  }
  
  for ch in route.children {
    env = iterate-docs(env, ch, path + (route.title,))
  }
  
  return env
}

#let load-docs() = {
  let m = json("/assets/artifacts/typst-docs-v0.11.0.json")
  let env = (funcs: (:), types: (:), scoped-items: (:))
  for route in m {
    env = iterate-docs(env, route, ())
  }
  
  return env
}

#let typst-v11 = load-docs()
