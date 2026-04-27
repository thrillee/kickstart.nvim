local java_21_home_dir = '/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home'
local java_17_home_dir = '/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home'
local java_11_home_dir = '/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home'

local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
local path_to_lsp_server = jdtls_path .. '/config_mac'
local path_to_plugins = jdtls_path .. '/plugins/'
local path_to_jar = vim.fn.glob(path_to_plugins .. 'org.eclipse.equinox.launcher_*.jar')
local lombok_path = vim.fn.glob(path_to_plugins .. 'lombok.jar')

-- Fallback to root-level lombok.jar (where mason places it)
if lombok_path == '' then
  lombok_path = jdtls_path .. '/lombok.jar'
end

local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', '<leader>dd', vim.diagnostic.setloclist, opts)
  vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>lf', function()
    require('conform').format()
  end, { buffer = bufnr, desc = 'Format Buffer' })
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- JDTLS command with Lombok support
local jdtls_cmd = {
  java_21_home_dir .. '/bin/java',
  '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  '-Dosgi.bundles.defaultStartLevel=4',
  '-Declipse.product=org.eclipse.jdt.ls.core.product',
  '-Dlog.protocol=true',
  '-Dlog.level=ALL',
  '-Xms1g',
  '--add-modules=ALL-SYSTEM',
  '--add-opens',
  'java.base/java.util=ALL-UNNAMED',
  '--add-opens',
  'java.base/java.lang=ALL-UNNAMED',
  '-javaagent:' .. lombok_path, -- Add Lombok as javaagent
  '-jar',
  path_to_jar,
  '-configuration',
  path_to_lsp_server,
  '-data',
  vim.fn.expand '~/.cache/jdtls-workspace' .. vim.fn.getcwd(),
}

vim.lsp.config('jdtls', {
  cmd = jdtls_cmd, -- Use the custom command with Lombok
  filetypes = { 'java' },
  capabilities = capabilities,
  root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-21',
            path = java_21_home_dir,
            default = true,
          },
        },
      },
    },
  },
  init_options = {
    bundles = {},
  },
})

vim.lsp.enable 'jdtls'

local function is_java_file()
  return vim.bo.filetype == 'java'
end

-- Function to run the Maven Wildfly redeploy command
local function redeploy_wildfly()
  vim.cmd '!mvn wildfly:redeploy'
end

-- Create the keymap
vim.keymap.set('n', '<leader>jd', function()
  if is_java_file() then
    redeploy_wildfly()
  else
    vim.notify 'This keymap only works for Java files.'
  end
end, { desc = 'Redeploy Wildfly' })

vim.diagnostic.config {
  virtual_text = true,
}
