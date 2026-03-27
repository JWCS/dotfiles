# tmux_functions.sh

maximize_vertical() {
  local panes active_pane active_left active_right non_active_panes num_panes fraction is_maximized
  panes=$(tmux lsp -s -F '#D #{pane_active} #{pane_left} #{pane_right} #{pane_top} #{pane_bottom}')

  read -r active_pane active_left active_right <<<$(echo "$panes" | awk '$2 == 1 {print $1, $3, $4}')

  is_maximized=$(echo "$panes" | awk -v al="$active_left" -v ar="$active_right" '$2 == 0 && ($3 >= al && $3 <= ar || $4 >= al && $4 <= ar) && $5 != $6 {exit 1} END {exit 0}')

  if [ $is_maximized -eq 0 ]; then
    # Maximize the active pane
    tmux resize-pane -y 100%
  else
    # Unmaximize the active pane
    non_active_panes=$(echo "$panes" | awk -v al="$active_left" -v ar="$active_right" '$2 == 0 && ($3 >= al && $3 <= ar || $4 >= al && $4 <= ar) {print $1}')
    num_panes=$(echo "$non_active_panes" | wc -l)
    fraction=$((100 / (num_panes + 1)))
    for guid in $non_active_panes; do
      tmux resize-pane -t "$guid" -y "$fraction%"
    done
  fi
}

