
// Components
import { CustomerTable } from "./components/CustomerTable";
import { ReservationTable } from "./components/ReservationTable";

export const Reservations = () => {
  return (
    <div className="px-[1.5rem]">
      <CustomerTable/>

      <ReservationTable/>
    </div>
  );
};
