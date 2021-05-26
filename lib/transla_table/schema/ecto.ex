defmodule TranslaTable.Schema.Ecto do
  @moduledoc false

  @doc """
  Retrieves the compile time configuration.
  """
  def compile_args(opts) do
    config = Application.get_env(:transla_table, :config, [])
    config = Keyword.merge(config, opts)

    schema = Keyword.fetch!(config, :schema)

    unless is_ecto_module?(schema) do
      raise ArgumentError, "invalid Ecto module"
    end

    locale_schema = Keyword.fetch!(config, :locale_schema)

    unless is_ecto_module?(locale_schema) do
      raise ArgumentError, "invalid Ecto locale module"
    end

    {_id, pk_type} = primary_key_type(schema)
    {_id, pk_lang_type} = primary_key_type(locale_schema)

    table = Keyword.get(opts, :table, schema.__schema__(:source)) |> String.to_atom()

    fields = get_ecto_field!(schema, Keyword.fetch!(opts, :fields))

    {{schema, pk_type}, table, fields, {locale_schema, pk_lang_type}}
  end

  defp get_ecto_field!(schema, fields) when is_list(fields) do
    Enum.map(fields, &get_ecto_field!(schema, &1))
  end

  defp get_ecto_field!(schema, field) when is_atom(field) do
    case schema.__schema__(:type, field) do
      nil -> raise ArgumentError, "invalid :#{field} key in Schema fields"
      type -> {field, type}
    end
  end

  defp get_ecto_field!(_schema, _field) do
    raise ArgumentError, "Not a valid field"
  end

  defp primary_key_type(schema) do
    [id | _rest] = schema.__schema__(:primary_key)
    get_ecto_field!(schema, id)
  end

  defp is_ecto_module?(schema) do
    try do
      schema.__schema__(:source)
      true
    rescue
      UndefinedFunctionError ->
        nil
    end
  end
end
