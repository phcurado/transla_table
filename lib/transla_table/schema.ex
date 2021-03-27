defmodule TranslaTable.Schema do
  @moduledoc false

  @doc """
  Retrieves the compile time configuration.
  """
  def compile_args(opts) do
    config = Application.get_env(:transla_table, :config, [])
    config = Keyword.merge(config, opts)

    module = Keyword.fetch!(config, :module)

    unless is_ecto_module?(module) do
      raise ArgumentError, "invalid Ecto module"
    end

    lang_mod = Keyword.fetch!(config, :lang_mod)

    unless is_ecto_module?(lang_mod) do
      raise ArgumentError, "invalid Ecto language module"
    end

    {_id, pk_type} = primary_key_type(module)
    {_id, pk_lang_type} = primary_key_type(lang_mod)

    table = Keyword.get(opts, :table, module.__schema__(:source)) |> String.to_atom()

    fields = get_ecto_field!(module, Keyword.fetch!(opts, :fields))

    {{module, pk_type}, table, fields, {lang_mod, pk_lang_type}}
  end

  defp get_ecto_field!(mod, fields) when is_list(fields) do
    Enum.map(fields, &get_ecto_field!(mod, &1))
  end

  defp get_ecto_field!(mod, field) when is_atom(field) do
    case mod.__schema__(:type, field) do
      nil -> raise ArgumentError, "invalid :#{field} key in Schema fields"
      type -> {field, type}
    end
  end

  defp get_ecto_field!(_mod, _field) do
    raise ArgumentError, "Not a valid field"
  end

  defp primary_key_type(mod) do
    [id | _rest] = mod.__schema__(:primary_key)
    get_ecto_field!(mod, id)
  end

  defp is_ecto_module?(mod) do
    try do
      mod.__schema__(:source)
      true
    rescue
      UndefinedFunctionError ->
        nil
    end
  end
end
