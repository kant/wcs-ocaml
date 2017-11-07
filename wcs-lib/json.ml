(*
 *  This file is part of the Watson Conversation Service OCaml API project.
 *
 * Copyright 2016-2017 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *)

open Wcs_t


(** {6 Utility function} *)

let read_json_file reader f =
  begin try
    let lexstate = Yojson.init_lexer ~fname:f () in
    let ch = open_in f in
    let lexbuf = Lexing.from_channel ch in
    let json = reader lexstate lexbuf in
    close_in ch;
    json
  with
  | Yojson.Json_error err ->
      Log.error "Json" None
        ("Unable to parse file "^f^": "^err)
  | exn ->
      Log.error "Json" None
        ("Unable to read file "^f^": "^(Printexc.to_string exn))
  end

let null : json = `Null

let set (ctx: json) (lbl: string) (v: json) : json =
  begin match ctx with
  | `Null -> `Assoc [ lbl, v ]
  | `Assoc l -> `Assoc ((lbl, v) :: (List.remove_assoc lbl l))
  | _ ->
      Log.error "Json"
        (Some ctx)
        "Unable to add a property to a non-object value"
  end

let take (ctx: json) (lbl: string) : json * json option =
  begin match ctx with
  | `Assoc l ->
      begin try
        let v = List.assoc lbl l in
        `Assoc (List.remove_assoc lbl l), Some v
      with Not_found ->
        ctx, None
      end
  | _ -> ctx, None
  end

let get (ctx: json) (lbl: string) : json option =
  begin try
    begin match Yojson.Basic.Util.member lbl ctx with
    | `Null -> None
    | x -> Some x
    end
  with _ ->
    None
  end

let assign (os: json list) : json =
  List.fold_left (fun acc o ->
    begin match o with
    | `Assoc l ->
        List.fold_right
          (fun (lbl, v) acc -> set acc lbl v)
          l acc
    | _ ->
        Log.error "Json" (Some acc) ""
    end)
    null os


(** {6 Settes and getters} *)

(** {8 Bool} *)

let set_bool (ctx: json) (lbl: string) (b: bool) : json =
  set ctx lbl (`Bool b)

let get_bool (ctx: json) (lbl: string) : bool option =
  begin match Yojson.Basic.Util.member lbl ctx with
  | `Bool b -> Some b
  | _ -> None
  end

(** {8 String} *)

let set_string (ctx: json) (lbl: string) (s: string) : json =
  set ctx lbl (`String s)

let get_string (ctx: json) (lbl: string) : string option =
  begin match get ctx lbl with
  | Some (`String s) -> Some s
  | _ -> None
  end

let take_string (ctx: json) (lbl: string) : json * string option =
  begin match take ctx lbl with
  | ctx, Some (`String s) -> ctx, Some s
  | ctx, _ -> ctx, None
  end


(** {6 Conversion of Wcs data structures to JSON} *)

let of_workspace_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_workspace_response rsp)

let of_pagination_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_pagination_response rsp)

let of_list_workspaces_request req =
  Yojson.Basic.from_string (Wcs_j.string_of_list_workspaces_request req)

let of_list_workspaces_response rsp =
  Yojson.Basic.from_string (Wcs_j.string_of_list_workspaces_response rsp)

let of_intent_example x =
  Yojson.Basic.from_string (Wcs_j.string_of_intent_example x)

let of_intent_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_intent_def x)

let of_entity_value x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity_value x)

let of_entity_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity_def x)

let of_next_step x =
  Yojson.Basic.from_string (Wcs_j.string_of_next_step x)

let of_output_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_output_def x)

let of_dialog_node x =
  Yojson.Basic.from_string (Wcs_j.string_of_dialog_node x)

let of_workspace x =
  Yojson.Basic.from_string (Wcs_j.string_of_workspace x)

let of_input x =
  Yojson.Basic.from_string (Wcs_j.string_of_input x)

let of_entity x =
  Yojson.Basic.from_string (Wcs_j.string_of_entity x)

let of_output x =
  Yojson.Basic.from_string (Wcs_j.string_of_output x)

let of_message_request x =
  Yojson.Basic.from_string (Wcs_j.string_of_message_request x)

let of_message_response x =
  Yojson.Basic.from_string (Wcs_j.string_of_message_response x)

let of_create_response x =
  Yojson.Basic.from_string (Wcs_j.string_of_create_response x)

let of_get_workspace_request x =
  Yojson.Basic.from_string (Wcs_j.string_of_get_workspace_request x)

let of_log_entry x =
  Yojson.Basic.from_string (Wcs_j.string_of_log_entry x)

let of_action x =
  Yojson.Basic.from_string (Wcs_j.string_of_action x)

let of_action_def x =
  Yojson.Basic.from_string (Wcs_j.string_of_action_def x)

let of_logs_request x =
  Yojson.Basic.from_string (Wcs_j.string_of_logs_request x)

let of_logs_response x =
  Yojson.Basic.from_string (Wcs_j.string_of_logs_response x)
