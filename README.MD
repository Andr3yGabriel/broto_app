# 🌱 Broto — App de Hábitos

> Cultive seus hábitos, dia após dia.

App mobile desenvolvido em **Flutter** para rastreamento de hábitos diários com streak, heatmap de progresso e notificações locais. Funciona **100% offline** — sem backend, sem autenticação, sem internet.

---

## Equipe

| Desenvolvedor | Foco principal |
| --- | --- |
| **Júlia** | Front-end, interfaces, widgets, animações, UX |
| **Andrey** | Dados, lógica de negócio, persistência, notificações |

---

## Stack

| Camada | Tecnologia |
| --- | --- |
| Framework | Flutter (Dart) |
| Gerência de estado | Riverpod |
| Navegação | go_router |
| Persistência local | Hive + hive_flutter |
| Notificações | flutter_local_notifications |
| Calendário | table_calendar |
| Gráficos | fl_chart |

---

## Estrutura de pastas

```text
lib/
├── main.dart
├── app.dart                        # MaterialApp + ThemeData + go_router
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # paleta roxa, fontes, espaçamentos
│   ├── router/
│   │   └── app_router.dart         # rotas nomeadas
│   └── constants/
│       └── app_icons.dart          # lista de ícones disponíveis
├── data/
│   ├── models/
│   │   ├── habit.dart              # modelo Hive: Habit
│   │   └── habit_log.dart          # modelo Hive: HabitLog
│   └── repositories/
│       ├── habit_repository.dart
│       └── log_repository.dart
├── domain/
│   └── services/
│       ├── streak_service.dart     # lógica de streak e taxa de conclusão
│       └── notification_service.dart
├── presentation/
│   ├── onboarding/
│   │   ├── onboarding_step1_screen.dart
│   │   ├── onboarding_step2_screen.dart
│   │   ├── onboarding_step3_screen.dart
│   │   └── onboarding_step4_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── habit/
│   │   ├── add_habit_step1_screen.dart
│   │   ├── add_habit_step2_screen.dart
│   │   ├── habit_detail_screen.dart
│   │   └── edit_habit_screen.dart
│   ├── stats/
│   │   └── stats_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── shared/
    └── widgets/
        ├── app_button.dart
        ├── habit_row_tile.dart
        ├── streak_card.dart
        ├── heatmap_grid.dart
        └── confirm_dialog.dart
```

---

## Modelos de dados

### `Habit`

```dart
@HiveType(typeId: 0)
class Habit extends HiveObject {
  int id;
  String name;
  String icon;       // nome do ícone Tabler
  String color;      // hex da cor
  String frequency;  // 'daily' | 'weekly' | 'weekdays'
  String? reminderTime; // 'HH:mm' ou null
  List<int> reminderDays; // [1,2,3,4,5] = seg–sex
  DateTime createdAt;
}
```

### `HabitLog`

```dart
@HiveType(typeId: 1)
class HabitLog extends HiveObject {
  int habitId;
  DateTime date;     // apenas a data, sem hora
  bool completed;
}
```

---

## Cronograma de desenvolvimento

**Período:** 11/05/2026 → 25/05/2026  
**Entrega final:** 25/05/2026

> As tarefas marcadas com 🟣 são de Júlia (front-end) e as marcadas com 🔵 são de Andrey (dados/lógica). Tarefas com ambas as cores exigem colaboração ou revisão cruzada.

---

### Sprint 1 — Fundação `11/05 → 14/05`

**Objetivo:** projeto rodando com estrutura definida, dados funcionando e tema aplicado.

#### Andrey - Sprint 1 🔵

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| A1.1 | Criar projeto Flutter e configurar `pubspec.yaml` com todas as dependências (Riverpod, go_router, Hive, flutter_local_notifications, table_calendar, fl_chart) | `flutter pub get` sem erros |
| A1.2 | Criar estrutura de pastas conforme definida acima | Pastas criadas com arquivos `.dart` vazios |
| A1.3 | Criar modelos `Habit` e `HabitLog` com anotações Hive (`@HiveType`, `@HiveField`) | Modelos compilam sem erros |
| A1.4 | Gerar adaptadores Hive com `build_runner` (`flutter pub run build_runner build`) | Arquivos `.g.dart` gerados corretamente |
| A1.5 | Implementar `HabitRepository`: `save()`, `getAll()`, `getById()`, `delete()` | Operações gravam e leem no Hive corretamente |
| A1.6 | Implementar `LogRepository`: `saveLog()`, `getLogsForHabit()`, `getLogsForDate()`, `deleteLogsForHabit()` | Logs associados ao `habitId` e `date` corretos |
| A1.7 | Criar `StreakService`: calcular `currentStreak`, `bestStreak` e `completionRate` a partir dos logs | Streak de 0 quando há furo; bestStreak histórico correto |
| A1.8 | Criar `HabitsNotifier` (Riverpod `StateNotifier`) com lista reativa de hábitos | `ref.watch(habitsProvider)` retorna lista atualizada após CRUD |
| A1.9 | Configurar `go_router` com todas as rotas: `/onboarding/*`, `/home`, `/habit/*`, `/stats`, `/notifications`, `/settings` | Navegação entre rotas sem erros de compilação |

#### Júlia - Sprint 1 🟣

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| J1.1 | Criar `app_theme.dart` com `ThemeData` completo: paleta roxa (`#7F77DD` accent, `#1E1B4B` background, `#2D2870` surface), fontes e border radius | Tema aplicado em toda a árvore sem override manual |
| J1.2 | Criar widget `AppButton` com variante primária (roxo sólido) e ghost (borda) | Botões renderizam corretamente em ambas as variantes |
| J1.3 | Criar widget `AppTextField` com estilo do protótipo (fundo `#2D2870`, borda `#534AB7`) | Campo aceita input e exibe placeholder corretamente |
| J1.4 | Criar widget `ConfirmDialog` reutilizável com título, descrição e dois botões (confirmar/cancelar) | Dialog exibido sobre overlay escurecido; retorna `bool` via `Navigator.pop` |
| J1.5 | Criar widget `HabitRowTile` com ícone, nome, streak e checkbox animado | Checkbox animado ao tocar; visual conforme protótipo |
| J1.6 | Criar widget `StreakCard` com número de dias, ícone de chama e melhor streak | Card renderiza valores passados via parâmetros |
| J1.7 | Criar `app_router.dart` configurando o `MaterialApp.router` com o `GoRouter` do Andrey | App inicializa sem erros e exibe a primeira tela |

---

### Sprint 2 — Onboarding + Home `14/05 → 18/05`

**Objetivo:** fluxo de onboarding completo e tela home funcional com check-in real.

#### Andrey - Sprint 2 🔵

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| A2.1 | Criar `OnboardingNotifier` com estado: nome do usuário, hábitos selecionados, horários configurados | Estado persiste entre etapas sem ser perdido |
| A2.2 | Salvar nome do usuário em `SharedPreferences` ao finalizar onboarding | Nome exibido na home em reinicializações do app |
| A2.3 | Implementar flag de onboarding concluído em `SharedPreferences`; configurar redirect no go_router: se concluído → `/home`, senão → `/onboarding/step1` | Usuário nunca volta ao onboarding após completar |
| A2.4 | Ao finalizar onboarding (etapa 4), salvar hábitos selecionados no Hive via `HabitRepository` | Hábitos aparecem na home imediatamente após onboarding |
| A2.5 | Implementar lógica de check-in: `LogRepository.toggleLog(habitId, date)` — cria log se não existe, remove se já existe | Toggle correto; logs não duplicados para a mesma data |
| A2.6 | Criar `DailyProgressNotifier`: total de hábitos do dia, quantos concluídos, saldo de progresso | `completedToday / totalToday` calculado corretamente |
| A2.7 | Configurar `NotificationService.initialize()` no `main.dart` com permissões iOS (`requestPermissions`) | Permissão solicitada na primeira abertura em iOS |
| A2.8 | Implementar `NotificationService.scheduleHabitReminder(habit)` com horário e dias da semana configurados | Notificação agendada com `flutter_local_notifications` no horário correto |

#### Júlia - Sprint 2 🟣

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| J2.1 | Implementar `OnboardingStep1Screen`: logo Broto centralizado, `AppTextField` para nome, botão "começar" | Navega para step2 ao confirmar; campo obrigatório validado |
| J2.2 | Implementar `OnboardingStep2Screen`: barra de progresso (2/4), chips de hábitos pré-definidos selecionáveis e opção "criar hábito próprio" | Chips toggle ao tocar; mínimo 1 selecionado para avançar |
| J2.3 | Implementar `OnboardingStep3Screen`: barra de progresso (3/4), lista de hábitos selecionados com horário editável por `TimePickerDialog` | Cada hábito tem horário independente; padrão 08:00 |
| J2.4 | Implementar `OnboardingStep4Screen`: barra de progresso (4/4), resumo dos hábitos criados com ícone e horário, botão "começar a brotar" | Exibe todos os hábitos com ícone e horário confirmados |
| J2.5 | Implementar `HomeScreen`: saudação com nome do usuário, barra de progresso do dia, `StreakCard`, lista de `HabitRowTile` com `FloatingActionButton` | Lista reativa ao estado do `HabitsNotifier` |
| J2.6 | Implementar estado vazio da `HomeScreen`: ilustração e botão "criar primeiro hábito" | Exibido quando `habits.isEmpty` |
| J2.7 | Implementar estado "dia perfeito" na `HomeScreen`: card especial de parabéns quando todos os hábitos estão concluídos | Card aparece quando `completedToday == totalToday && totalToday > 0` |
| J2.8 | Implementar animação de check no `HabitRowTile`: `AnimatedContainer` que transita de círculo vazio para preenchido com ícone de check | Animação suave de 200ms ao tocar |

---

### Sprint 3 — Hábito (CRUD) + Detalhe `18/05 → 21/05`

**Objetivo:** fluxo completo de criar, editar, visualizar e excluir hábitos.

#### Andrey - Sprint 3 🔵

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| A3.1 | Criar `HabitFormNotifier`: gerencia estado do formulário de criação/edição (nome, ícone, cor, frequência, lembrete, dias) | Estado não é perdido ao navegar entre step1 e step2 |
| A3.2 | Ao salvar novo hábito: persistir no Hive via `HabitRepository.save()` e agendar notificação via `NotificationService` | Hábito aparece na home e notificação agendada imediatamente |
| A3.3 | Ao editar hábito: atualizar no Hive e reagendar notificação (cancelar anterior, criar nova) | Alterações refletidas na home sem reiniciar o app |
| A3.4 | Ao excluir hábito: remover do Hive, remover todos os logs associados e cancelar notificação | Hábito e logs desaparecem; notificação cancelada |
| A3.5 | Implementar `StreakService.getCalendarData(habitId, month)`: retorna `Map<DateTime, bool>` com dias concluídos no mês | Dados corretos para alimentar o `table_calendar` |
| A3.6 | Implementar `StreakService.getCompletionRate(habitId, {DateTime? from, DateTime? to})` | Taxa calculada como `diasConcluídos / diasEsperados` no período |

#### Júlia - Sprint 3 🟣

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| J3.1 | Implementar `AddHabitStep1Screen`: campo de nome, grade de ícones (4 colunas), seletor de cor em círculos, seletor de frequência (3 opções) | Validação: nome obrigatório, ícone obrigatório |
| J3.2 | Implementar `AddHabitStep2Screen`: toggle de lembrete, `TimePicker` para horário, seletor de dias da semana (botões circulares D S T Q Q S S) | Dias desabilitados quando lembrete está desativado |
| J3.3 | Implementar `HabitDetailScreen`: card de hero com ícone/nome/horário, três stat cards (sequência atual, melhor, taxa), `TableCalendar` com dias marcados | Calendário navega entre meses; dias concluídos destacados em roxo |
| J3.4 | Implementar `EditHabitScreen`: formulário pré-populado com dados do hábito existente, botão de excluir no rodapé | Formulário exibe valores atuais; botão excluir abre `ConfirmDialog` |
| J3.5 | Implementar swipe para excluir no `HabitRowTile` da `HomeScreen` com `Dismissible` e `ConfirmDialog` | Hábito só é excluído após confirmação; undo não disponível |
| J3.6 | Implementar `CategoryPicker` como `BottomSheet` com grade de ícones e busca por nome | Ícone selecionado refletido imediatamente no formulário |

---

### Sprint 4 — Estatísticas + Notificações + Configurações + Polimento `21/05 → 25/05`

**Objetivo:** telas secundárias completas, app polido e pronto para apresentação.

#### Andrey - Sprint 4 🔵

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| A4.1 | Implementar `StatsNotifier`: agrega streak geral, taxa geral, total de hábitos ativos, melhor streak histórico | Valores calculados corretamente com base nos logs do Hive |
| A4.2 | Implementar `StatsNotifier.getWeeklyData()`: retorna lista de 7 valores (0.0–1.0) com taxa de conclusão diária dos últimos 7 dias | Dados alimentam o `BarChart` do fl_chart |
| A4.3 | Implementar `StatsNotifier.getHeatmapData()`: retorna `Map<DateTime, int>` com intensidade (0–4) por dia nas últimas 5 semanas | Intensidade proporcional ao número de hábitos concluídos no dia |
| A4.4 | Implementar `NotificationLog`: registrar notificações recebidas no Hive para exibição na tela de notificações | Lista de notificações persiste entre sessões |
| A4.5 | Implementar `SettingsRepository`: salvar e ler preferências (modo escuro, lembretes ativos, resumo noturno, alerta de streak) em `SharedPreferences` | Preferências persistem após fechar o app |
| A4.6 | Implementar lógica de redefinição de dados: limpar todos os boxes do Hive, cancelar todas as notificações e redirecionar para onboarding | Após redefinição, app volta ao estado inicial completo |
| A4.7 | Configurar `Info.plist` para iOS: `NSUserNotificationsUsageDescription` e `UIBackgroundModes` para notificações em background | Notificações funcionam com app em background no simulador |
| A4.8 | Testar app no simulador iOS (Xcode) e em dispositivo físico: verificar notificações, persistência e navegação | Nenhum crash; notificações chegam no horário configurado |

#### Júlia - Sprint 4 🟣

| # | Tarefa | Critério de aceite |
| --- | --- | --- |
| J4.1 | Implementar `StatsScreen`: quatro stat cards em grid 2×2, `BarChart` de 7 dias (fl_chart), `HeatmapGrid` com legenda de intensidade | Dados vindos do `StatsNotifier`; gráficos renderizados corretamente |
| J4.2 | Criar widget `HeatmapGrid`: grid 7×5 de células coloridas com intensidade 0–4 em tons de roxo | Células respondem aos dados do `StatsNotifier.getHeatmapData()` |
| J4.3 | Implementar `NotificationsScreen`: lista de notificações recentes com ícone, título, corpo e hora relativa | Lista vazia exibe estado "nenhuma notificação ainda" |
| J4.4 | Implementar `SettingsScreen`: avatar com inicial do nome, seção de notificações com 3 toggles, seção de aparência com toggle de modo escuro, botão de redefinir dados | Toggles refletem estado do `SettingsRepository`; redefinir abre `ConfirmDialog` |
| J4.5 | Implementar animação de streak na `HomeScreen`: número de dias com `AnimatedSwitcher` ao atualizar | Troca de número animada ao completar hábitos |
| J4.6 | Adicionar shimmer loading nos `HabitRowTile` enquanto dados carregam do Hive | Placeholder visível por no mínimo 1 frame antes dos dados |
| J4.7 | Revisar todas as telas: `dart format`, `dart analyze` sem warnings, ajustes de espaçamento e consistência visual | Zero warnings no `dart analyze` |
| J4.8 | Montar slides de apresentação: capturas de tela do app, fluxo de uso e decisões técnicas tomadas | Slides prontos para 25/05 |

---

## Resumo de responsabilidades

```text
Andrey (🔵) — dados, lógica, infraestrutura
├── Modelos Hive (Habit, HabitLog)
├── Repositories (HabitRepository, LogRepository)
├── Services (StreakService, NotificationService)
├── Notifiers Riverpod (HabitsNotifier, DailyProgressNotifier,
│   OnboardingNotifier, HabitFormNotifier, StatsNotifier)
├── Persistência de configurações (SharedPreferences)
├── Lógica de onboarding (flag, redirect, salvamento)
├── Configuração iOS (Info.plist, permissões)
└── Testes no simulador e dispositivo físico

Júlia (🟣) — interfaces, widgets, UX
├── ThemeData global (paleta roxa)
├── Widgets compartilhados (AppButton, AppTextField,
│   ConfirmDialog, HabitRowTile, StreakCard, HeatmapGrid)
├── Onboarding (4 telas)
├── HomeScreen (estados: padrão, vazio, dia perfeito)
├── AddHabit (2 telas: configuração + lembrete)
├── HabitDetailScreen + EditHabitScreen
├── StatsScreen + NotificationsScreen + SettingsScreen
├── Animações (check-in, streak, shimmer)
└── Slides de apresentação
```

---

## Como rodar o projeto

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/broto.git
cd broto

# Instalar dependências
flutter pub get

# Gerar adaptadores Hive (Andrey)
flutter pub run build_runner build --delete-conflicting-outputs

# Rodar no simulador iOS
open -a Simulator
flutter run

# Rodar em dispositivo físico (conectado via cabo)
flutter run --release
```

### Dependências do `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_local_notifications: ^17.2.2
  table_calendar: ^3.1.2
  fl_chart: ^0.68.0
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  flutter_lints: ^4.0.0
```

---

## Entrega

**Data:** 25/05/2026  
**Formato:** apresentação ao vivo com demonstração no simulador iOS  
**Repositório:** este README deve estar atualizado com instruções de execução antes da apresentação
